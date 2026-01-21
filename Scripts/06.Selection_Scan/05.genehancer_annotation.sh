#!/bin/bash
# ==============================================================================
# Script Name: 05.genehancer_annotation.sh
# Description: Annotate SVs with Enhancer information using GeneHancer database.
# Tools used: bedtools
# ==============================================================================
GH_BED="/path/to/GeneHancer_hg38.bed"
GH_ASSOC="/path/to/GeneHancer_gene_association_scores.txt"

# Input/Output paths
INPUT_DIR="../06.Selection_Scan/di_output/top_0.01"
OUTPUT_DIR="./enhancer_annotation"
mkdir -p ${OUTPUT_DIR}/gene_lists ${OUTPUT_DIR}/annotated_beds

# Populations
POPS="Amhara Chabu Dizi Hadza Herero Fulani Mursi Sandawe Tikari RHG Ju Xoo Ju_Xoo"

# ================= Main Loop =================
for i in ${POPS}; do
    echo "Processing ${i}..."
    PREFIX="${OUTPUT_DIR}/${i}"
    bedtools intersect -a ${INPUT_DIR}/${i}.0.01.chr.pos.bed -b ${GH_BED} -wa -wb > ${PREFIX}_gh.bed
    awk 'BEGIN {FS=OFS="\t"} NR==FNR{a[$9]=$0; next} ($1 in a){print a[$1],$2}' \
        ${PREFIX}_gh.bed ${GH_ASSOC} > ${PREFIX}_gh_merged.out
    sed -i '1i\SV_chr\tPOS\tEND\tLEN\tID\tgenehancer_chr\tpos\tend\tGH\tNo\tSymbol' ${PREFIX}_gh_merged.out
    awk -v OFS='\t' '{n=split($NF,a,","); for(j=1;j<=n;j++){$NF=a[j]; print}}' \
        ${PREFIX}_gh_merged.out > ${PREFIX}_gh_split.out

    # Extract Genes
    awk 'NR>1{print $11}' ${PREFIX}_gh_split.out | sort -u > ${OUTPUT_DIR}/gene_lists/${i}.gene
    # Extract SV Coordinates
    awk -v OFS='\t' 'NR>1{print $1,$2,$3,$4}' ${PREFIX}_gh_merged.out | sort -u > ${OUTPUT_DIR}/annotated_beds/${i}_gh_sv.bed
done

echo "Done. Results in ${OUTPUT_DIR}"
