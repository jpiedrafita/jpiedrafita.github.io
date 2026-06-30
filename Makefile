.PHONY: preview pdf analyze

PORT ?= 8000
ANALYZE_LANG ?= es

preview:
	python3 -m http.server $(PORT)

pdf:
	./scripts/export-pdf.sh

analyze:
	bash .opencode/skills/cv-analyzer/scripts/analyze-cv.sh . $(ANALYZE_LANG)
