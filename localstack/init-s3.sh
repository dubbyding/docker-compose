#!/usr/bin/env bash
set -euo pipefail

# This script runs inside the LocalStack container via /etc/localstack/init/ready.d/
# It will:
#  - create buckets listed in $BUCKETS (comma-separated)
#  - disable S3 public access block for each bucket
#  - attach a public-read bucket policy
#  - enable static website hosting on each bucket
#  - optionally upload a small index.html to each bucket (if UPLOAD_SAMPLE=1)

AWS_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
ENDPOINT="http://localhost:4566"
BUCKETS="${BUCKETS:-local-public-bucket,local-site-bucket}"
UPLOAD_SAMPLE="${UPLOAD_SAMPLE:-1}"

log() { printf '%s %s\n' "$(date --iso-8601=seconds 2>/dev/null || date)" "$*"; }

# use awslocal if present (bundled with LocalStack); else fall back to aws cli with --endpoint-url
detect_client() {
  if command -v awslocal >/dev/null 2>&1; then
    CLIENT_CMD="awslocal"
    log "Using 'awslocal' client."
  elif command -v aws >/dev/null 2>&1; then
    CLIENT_CMD="aws --endpoint-url ${ENDPOINT} --region ${AWS_REGION} --no-verify-ssl"
    log "Using 'aws' CLI with endpoint ${ENDPOINT}."
  else
    log "ERROR: neither 'awslocal' nor 'aws' CLI found in container. Aborting."
    exit 1
  fi
}

wait_for_localstack() {
  log "Waiting for LocalStack health endpoint..."
  retries=0
  until curl -sSf "${ENDPOINT}/_localstack/health" >/dev/null 2>&1 || curl -sSf "${ENDPOINT}/health" >/dev/null 2>&1; do
    sleep 1
    retries=$((retries+1))
    if [ $retries -ge 60 ]; then
      log "Timed out waiting for LocalStack after ${retries}s"
      return 1
    fi
  done
  log "LocalStack is healthy."
}

create_bucket_if_missing() {
  local bucket="$1"
  # create-bucket differs for us-east-1 vs other regions
  if [[ "${AWS_REGION}" == "us-east-1" ]]; then
    eval "${CLIENT_CMD} s3 mb s3://${bucket} || true"
  else
    eval "${CLIENT_CMD} s3api create-bucket --bucket ${bucket} --create-bucket-configuration LocationConstraint=${AWS_REGION} || true"
  fi
}

disable_public_block() {
  local bucket="$1"
  # Turn off block public access so bucket policies can make objects public
  local payload='{"BlockPublicAcls":false,"IgnorePublicAcls":false,"BlockPublicPolicy":false,"RestrictPublicBuckets":false}'
  echo "${payload}" > /tmp/public-block.json
  eval "${CLIENT_CMD} s3api delete-public-access-block --bucket ${bucket} 2>/dev/null || true"
  # Some aws versions support put-public-access-block; using put to be explicit
  eval "${CLIENT_CMD} s3api put-public-access-block --bucket ${bucket} --public-access-block-configuration '${payload}' || true"
  log "Disabled public access block for ${bucket} (if supported)."
}

attach_public_policy() {
  local bucket="$1"
  cat > /tmp/bucket-policy.json <<POL
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"PublicReadGetObject",
      "Effect":"Allow",
      "Principal":"*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${bucket}/*"]
    }
  ]
}
POL
  eval "${CLIENT_CMD} s3api put-bucket-policy --bucket ${bucket} --policy file:///tmp/bucket-policy.json || true"
  log "Attached public-read policy to ${bucket}."
}

enable_website_hosting() {
  local bucket="$1"
  # Configure website with index.html and error.html
  cat > /tmp/website.json <<WEB
{
  "IndexDocument": {"Suffix":"index.html"},
  "ErrorDocument": {"Key":"error.html"}
}
WEB
  eval "${CLIENT_CMD} s3api put-bucket-website --bucket ${bucket} --website-configuration file:///tmp/website.json || true"
  log "Enabled static website hosting for ${bucket}."
}

upload_sample_index() {
  local bucket="$1"
  if [[ "${UPLOAD_SAMPLE}" == "1" ]]; then
    # tiny sample index and error page
    echo "<html><head><meta charset='utf-8'><title>${bucket}</title></head><body><h1>Welcome to ${bucket} (LocalStack)</h1></body></html>" > /tmp/index.html
    echo "<html><head><meta charset='utf-8'><title>error</title></head><body><h1>Not found</h1></body></html>" > /tmp/error.html

    # upload (using put-object so location constraint etc. not needed)
    eval "${CLIENT_CMD} s3 cp /tmp/index.html s3://${bucket}/index.html || true"
    eval "${CLIENT_CMD} s3 cp /tmp/error.html s3://${bucket}/error.html || true"

    # ensure the uploaded objects are publicly readable (in case bucket ACLs not applied automatically)
    # Note: modern AWS discourages ACLs; bucket policy added above grants GetObject to everyone.
    eval "${CLIENT_CMD} s3api put-object-acl --bucket ${bucket} --key index.html --acl public-read || true"
    eval "${CLIENT_CMD} s3api put-object-acl --bucket ${bucket} --key error.html --acl public-read || true"

    log "Uploaded sample index.html and error.html to ${bucket}."
  fi
}

main() {
  log "S3 init script starting..."
  wait_for_localstack
  detect_client

  IFS=',' read -r -a buckets_arr <<< "${BUCKETS}"

  for raw in "${buckets_arr[@]}"; do
    bucket="$(echo "${raw}" | xargs)" # trim
    if [ -z "${bucket}" ]; then
      continue
    fi
    log "Processing bucket: ${bucket}"
    create_bucket_if_missing "${bucket}"
    disable_public_block "${bucket}"
    attach_public_policy "${bucket}"
    enable_website_hosting "${bucket}"
    upload_sample_index "${bucket}"
    log "Bucket ${bucket} prepared and public."
  done

  log "S3 initialization finished."
}

main "$@"
