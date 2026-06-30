# Printable CV Workflow

This branch contains the general printable/PDF version of the CV.

## Branches

- `main`: public web CV published through GitHub Pages.
- `print`: permanent base branch for the general printable CV.
- `process/...`: process-specific branches created from `print`.

Do not make process-specific edits on `main` or `print`. Keep `print` as the reusable baseline and branch from it for each selection process.

## Preview

From the repository root:

```bash
python3 -m http.server 8000
```

Open:

```text
http://localhost:8000/
```

## Export PDF

From the repository root:

```bash
./scripts/export-pdf.sh
```

The generated PDF is written to:

```text
dist/jorge-piedrafita-cv.pdf
```

The `dist/` directory is ignored by Git. Do not commit generated PDFs.

The export script uses Chrome, Chromium, or Microsoft Edge in headless mode. If no compatible browser is found, start the preview server manually and use the browser print dialog:

```text
Print > Save as PDF
```

## Analyze The PDF

From `print` or a `process/...` branch:

```bash
bash .opencode/skills/cv-analyzer/scripts/analyze-cv.sh . es
```

The analyzer script generates the PDF first and sends `dist/jorge-piedrafita-cv.pdf` to the CV analyzer. It saves the response to:

```text
cv-analysis.json
```

`cv-analysis.json` is ignored by Git.

## Create A Process-Specific CV

Create branches for selection processes from `print`:

```bash
git switch print
git switch -c process/company-role
```

Then adapt the profile, skills, and achievements for that specific process and export a PDF from that branch.

## Editing Rules

- Keep `main` focused on the public web CV.
- Keep `print` as the general printable CV.
- Put company- or role-specific changes only in `process/...` branches.
- Do not commit files under `dist/`.
- Do not commit `cv-analysis.json`.
- Keep the printable version compact, readable, and suitable for one to two A4 pages.
