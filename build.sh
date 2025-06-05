#!/bin/bash

# Остановка при ошибке
set -e

# === Параметры ===
TEX_FILE="kursach.tex"
PDF_OUTPUT="kursach.pdf"
DOCX_OUTPUT="kursach.docx"
BIB_FILE="bib/kursach.bib"

CSL_MINIMAL="gost-minimal.csl"
CSL_FULL="gost-r-7-0-5-2008-numeric-alphabetical.csl"

# === Список временных файлов для удаления ===
AUX_EXTENSIONS=(
  *.aux *.bbl *.bcf *.blg *.log *.out *.run.xml *.toc
  *.lof *.lot *.fdb_latexmk *.fls
)

# === Функция очистки ===
clean_aux_files() {
  echo "🧹 Очистка временных файлов..."
  for ext in "${AUX_EXTENSIONS[@]}"; do
    rm -rf "${ext}"
  done
  echo "✅ Очистка завершена"
}

# === Проверка параметров ===
STYLE="${1:-full}"  # по умолчанию full

if [[ "$STYLE" == "minimal" ]]; then
  CSL_FILE="$CSL_MINIMAL"
elif [[ "$STYLE" == "full" ]]; then
  CSL_FILE="$CSL_FULL"
else
  echo "❌ Неизвестный стиль: $STYLE"
  echo "Использование: ./build.sh [minimal|full]"
  exit 1
fi

# === Сборка PDF ===
echo "📄 Сборка PDF..."
pdflatex "$TEX_FILE"
biber "${TEX_FILE%.tex}"
pdflatex "$TEX_FILE"
pdflatex "$TEX_FILE"
echo "✅ PDF собран: $PDF_OUTPUT"

# === Сборка Word ===
echo "📝 Сборка DOCX с CSL-стилем '$STYLE'..."
pandoc "$TEX_FILE" \
  --from=latex \
  --citeproc \
  --bibliography="$BIB_FILE" \
  --csl="$CSL_FILE" \
  --resource-path=. \
  -o "$DOCX_OUTPUT"
echo "✅ DOCX собран: $DOCX_OUTPUT"

# === Очистка ===
clean_aux_files

