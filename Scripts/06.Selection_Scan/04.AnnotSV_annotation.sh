#!/bin/bash
# Script: 04.AnnotSV_annotation.sh
# Description: Gene-based annotation of Di-SVs using AnnotSV (v3.4.2).
# Tools: AnnotSV (v3.4.2)
# ==============================================================================

# ================= Config =================
ANNOTSV="AnnotSV"
INPUT_DIR="../06.Selection_Scan/di_output/top_0.01"
OUTPUT_DIR="./annotsv_output"
mkdir -p ${OUTPUT_DIR}
POPS="Amhara Chabu Dizi Hadza Herero Fulani Mursi Sandawe Tikari RHG Ju Xoo Ju_Xoo"
GENOME_BUILD="GRCh38"

# ================= Main Loop =================
for i in ${POPS}; do
    echo "Processing ${i}..."
    INPUT_FILE="${INPUT_DIR}/${i}.0.01.chr.pos.bed"  # Input BED file (from Top 1% Di results)
    ${ANNOTSV} \
        -SVinputFile "${INPUT_FILE}" \
        -outputFile "${OUTPUT_DIR}/${i}.annotsv.tsv" \
        -genomeBuild ${GENOME_BUILD} \
done

echo "AnnotSV processing finished. Results in ${OUTPUT_DIR}"
