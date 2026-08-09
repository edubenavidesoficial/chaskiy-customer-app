#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 ]]; then
  echo "Uso: bash tool/publish_companion_apk.sh <driver|vendor> <version> <archivo.apk> <s3://bucket> [cloudfront-distribution-id]"
  exit 1
fi

app="$1"
version="$2"
apk_path="$3"
s3_bucket="${4%/}"
distribution_id="${5:-}"

if [[ "$app" != "driver" && "$app" != "vendor" ]]; then
  echo "La aplicación debe ser driver o vendor."
  exit 1
fi

if [[ ! -f "$apk_path" ]]; then
  echo "No existe el APK: $apk_path"
  exit 1
fi

content_type="application/vnd.android.package-archive"
versioned_key="$app/$app-$version.apk"
latest_key="$app/latest.apk"

aws s3 cp "$apk_path" "$s3_bucket/$versioned_key" \
  --content-type "$content_type"
aws s3 cp "$apk_path" "$s3_bucket/$latest_key" \
  --content-type "$content_type" \
  --cache-control "no-cache, no-store, must-revalidate"

if [[ -n "$distribution_id" ]]; then
  aws cloudfront create-invalidation \
    --distribution-id "$distribution_id" \
    --paths "/$latest_key"
fi

echo "Publicación terminada:"
echo "- $versioned_key"
echo "- $latest_key"
