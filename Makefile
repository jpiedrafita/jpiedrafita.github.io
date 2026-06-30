.PHONY: preview pdf analyze explain-analysis analyze-agent

PORT ?= 8000
ANALYZE_LANG ?= es

preview:
	python3 -m http.server $(PORT)

pdf:
	./scripts/export-pdf.sh

analyze:
	bash .opencode/skills/cv-analyzer/scripts/analyze-cv.sh . $(ANALYZE_LANG)

explain-analysis:
	@test -f dist/cv-analysis.json || (echo "dist/cv-analysis.json not found. Run 'make analyze' first." >&2; exit 1)
	opencode run --dir . "Use the cv-analyzer skill output guidance. Read dist/cv-analysis.json and explain the analyzer result in Spanish. Lead with the score and headline, then summarize the most important findings, prioritize actionable changes, and distinguish analyzer suggestions from verified CV facts. Do not modify files."

analyze-agent: analyze explain-analysis
