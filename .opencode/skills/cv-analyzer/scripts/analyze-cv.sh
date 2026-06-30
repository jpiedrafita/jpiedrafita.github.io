#!/usr/bin/env bash
set -euo pipefail

repo_root="${1:-.}"
lang="${2:-es}"

dist_dir="$repo_root/dist"
export_script="$repo_root/scripts/export-pdf.sh"
cv_file="$dist_dir/jorge-piedrafita-cv.pdf"
analysis_file="$dist_dir/cv-analysis.json"

if [[ ! -x "$export_script" ]]; then
  printf 'error: PDF export script not found or not executable at %s\n' "$export_script" >&2
  exit 1
fi

if [[ "$lang" != "es" && "$lang" != "en" ]]; then
  printf 'error: lang must be es or en\n' >&2
  exit 1
fi

command -v python3 >/dev/null 2>&1 || { printf 'error: python3 is required\n' >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { printf 'error: curl is required\n' >&2; exit 1; }

mkdir -p "$dist_dir"
"$export_script"

if [[ ! -f "$cv_file" ]]; then
  printf 'error: generated PDF not found at %s\n' "$cv_file" >&2
  exit 1
fi

tmp_response="$(mktemp)"
trap 'rm -f "$tmp_response"' EXIT

curl -sS -f -X POST "https://cv.nan.builders/api/analyze" \
  -F "cv=@${cv_file};type=application/pdf" \
  -F "lang=${lang}" \
  -o "$tmp_response"

python3 - "$tmp_response" "$analysis_file" <<'PY'
import json
import sys

source, dest = sys.argv[1], sys.argv[2]
with open(source, "r", encoding="utf-8") as f:
    payload = json.load(f)

payload.pop("_cvText", None)

with open(dest, "w", encoding="utf-8") as f:
    json.dump(payload, f, ensure_ascii=False, indent=2)
    f.write("\n")

print(f"score: {payload.get('overallScore')}")
print(f"headline: {payload.get('headline')}")
priorities = payload.get("topPriorities") or []
if priorities:
    print("top priorities:")
    for item in priorities:
        print(f"- {item}")
PY

printf 'analyzed %s\n' "$cv_file"
printf 'wrote %s\n' "$analysis_file"
