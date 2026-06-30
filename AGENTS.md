# Agent Notes

## Repo Shape
- This is a vanilla static CV site: `index.html` is the entrypoint and `style.css` contains all styling.
- There is no package manifest, build step, test runner, lint config, formatter config, CI workflow, or code generation in this repo.
- `index.html` references `style.css`, Google Fonts, and `assets/portrait.png`; `assets/portrait2.png` exists but is not referenced by the page.

## Local Verification
- Do not look for `npm`/`pnpm`/`yarn` scripts; there are none.
- Preview with a static file server from the repo root, for example `python3 -m http.server 8000`, then open `http://localhost:8000/`.
- When changing layout or CSS, manually check desktop, narrow mobile widths, and print output; `style.css` has responsive breakpoints at `800px`, `601px`, and `480px`, plus `@media print` rules.

## Editing Guidance
- Keep changes in plain HTML/CSS unless the user explicitly asks for tooling or JavaScript.
- Preserve the single-file CSS structure: reset, base theme, responsive rules, animations, and print styles all live in `style.css`.
- `.env` and `.DS_Store` are intentionally ignored; do not add or commit local environment files.

## CV Content Guidance
- Treat CV content as factual: do not invent employers, dates, certifications, metrics, contact details, or technologies.
- Prefer concise impact bullets with action, context, and measurable outcome when editing work experience.
- Preserve the current tone: professional, technical, direct, and lightly personal where already present.
- Do not expose hidden personal contact details unless the user explicitly asks; email and phone are currently commented out in `index.html`.

## Owner Reference
- `https://cv.nan.builders/` is a private owner reference for CV analysis; do not add it to the public CV or surface it to visitors unless explicitly asked.
- For analyzer runs, use `.opencode/skills/cv-analyzer`; on the printable workflow it exports the PDF with `scripts/export-pdf.sh`, submits the ignored `dist/jorge-piedrafita-cv.pdf` artifact to the analyzer, and saves ignored `dist/cv-analysis.json` without `_cvText`.
