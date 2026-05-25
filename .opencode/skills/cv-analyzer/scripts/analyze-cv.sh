#!/usr/bin/env bash
set -euo pipefail

repo_root="${1:-.}"
lang="${2:-es}"

index_file="$repo_root/index.html"
cv_file="$repo_root/cv.txt"
analysis_file="$repo_root/cv-analysis.json"

if [[ ! -f "$index_file" ]]; then
  printf 'error: index.html not found at %s\n' "$index_file" >&2
  exit 1
fi

if [[ "$lang" != "es" && "$lang" != "en" ]]; then
  printf 'error: lang must be es or en\n' >&2
  exit 1
fi

command -v python3 >/dev/null 2>&1 || { printf 'error: python3 is required\n' >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { printf 'error: curl is required\n' >&2; exit 1; }

python3 - "$index_file" "$cv_file" <<'PY'
import html
import re
import sys
from html.parser import HTMLParser

source, dest = sys.argv[1], sys.argv[2]

BLOCK_TAGS = {
    "address", "article", "aside", "blockquote", "br", "div", "footer",
    "h1", "h2", "h3", "h4", "h5", "h6", "header", "hr", "li", "main",
    "nav", "ol", "p", "section", "table", "td", "th", "tr", "ul",
}


class VisibleTextParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.parts = []
        self.skip_depth = 0
        self.href_stack = []

    def handle_starttag(self, tag, attrs):
        if tag in {"script", "style", "noscript"}:
            self.skip_depth += 1
            return
        if self.skip_depth:
            return
        if tag in BLOCK_TAGS:
            self.parts.append("\n")
        if tag == "a":
            href = dict(attrs).get("href")
            self.href_stack.append(href)

    def handle_endtag(self, tag):
        if tag in {"script", "style", "noscript"} and self.skip_depth:
            self.skip_depth -= 1
            return
        if self.skip_depth:
            return
        if tag == "a" and self.href_stack:
            self.href_stack.pop()
        if tag in BLOCK_TAGS:
            self.parts.append("\n")

    def handle_data(self, data):
        if self.skip_depth:
            return
        text = " ".join(data.split())
        if not text:
            return
        if self.href_stack and self.href_stack[-1] and self.href_stack[-1] != text:
            text = f"{text} ({self.href_stack[-1]})"
        self.parts.append(text)

    def handle_comment(self, data):
        # Comments can contain hidden personal contact details; intentionally ignored.
        return


parser = VisibleTextParser()
with open(source, "r", encoding="utf-8") as f:
    parser.feed(f.read())

text = " ".join(parser.parts)
text = html.unescape(text)
text = re.sub(r"[ \t]+", " ", text)
text = re.sub(r"\s*\n\s*", "\n", text)
text = re.sub(r"\n{3,}", "\n\n", text).strip() + "\n"

with open(dest, "w", encoding="utf-8") as f:
    f.write(text)
PY

tmp_response="$(mktemp)"
trap 'rm -f "$tmp_response"' EXIT

curl -sS -f -X POST "https://cv.nan.builders/api/analyze" \
  -F "cv=@${cv_file};type=text/plain" \
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

printf 'wrote %s\n' "$cv_file"
printf 'wrote %s\n' "$analysis_file"
