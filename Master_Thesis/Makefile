LATEXMK := latexmk -pdfxe -interaction=nonstopmode -synctex=1

DOCUMENT := Thesis

.PHONY: document clean

document:
	$(LATEXMK) -jobname=$(DOCUMENT) $(DOCUMENT).tex

clean:
	latexmk -C
