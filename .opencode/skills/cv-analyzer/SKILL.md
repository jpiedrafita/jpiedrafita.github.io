---
name: cv-analyzer
description: Export this static CV site to plain text and submit it to the owner CV analyzer at cv.nan.builders.
argument-hint: "[repo-root] [es|en]"
user-invocable: true
license: MIT
---

# cv-analyzer

Purpose: Automate the CV analysis loop for this static CV repository.

## When to Use

- The user asks to analyze, score, review, or improve the CV using `https://cv.nan.builders/`.
- The user asks to regenerate the plain-text CV export for ATS/CV analysis.

## Repo Assumptions

- This repo is a static CV site with `index.html` as the source of truth.
- Hidden contact details may exist in HTML comments; do not include commented-out email or phone values in exports.
- The analyzer accepts `.txt` through `POST https://cv.nan.builders/api/analyze` with `FormData` fields `cv` and `lang`.

## Workflow

1. Run the bundled script from the repo root:

```bash
bash .opencode/skills/cv-analyzer/scripts/analyze-cv.sh . es
```

2. Review generated files:

- `cv.txt`: visible CV content extracted from `index.html`.
- `cv-analysis.json`: analyzer response with `_cvText` removed before saving.

3. Report the score, headline, and top priorities. Do not blindly apply analyzer suggestions; preserve factual accuracy and ask before adding private contact details.

## Output Guidance

- Lead with the analyzer score and the top actionable findings.
- Distinguish analyzer suggestions from verified CV facts.
- If suggesting edits, keep them concise and aligned with the existing CV tone.

## Safety

- Running the script sends the public CV text to `cv.nan.builders`.
- Do not send `.env`, hidden contact details, or commented-out HTML content.
- Do not publish the analyzer URL in `index.html` unless the user explicitly asks.
