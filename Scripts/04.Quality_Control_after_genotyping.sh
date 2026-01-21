#!/bin/bash

# ==============================================================================
# Script Name: 04.Quality_Control_after_genotyping.sh
# Description: SV Quality Control Filtering.
# Tools used: BCFtools, VCFtools v0.1.16
# ==============================================================================


# ==========================================
# 1. Configuration
# ==========================================
BCFTOOLS="bcftools"
VCFTOOLS="vcftools"

# Input Configuration
INPUT_VCF="merge_wgs180.vcf.gz"
# Output Configuration
OUTPUT_DIR="./qc_output"
# Intermediate file (Autosomes only)
AUTO_VCF="${OUTPUT_DIR}/Wgs180_auto.vcf.gz"
# Final Output file (Filtered)
FINAL_QC_VCF="${OUTPUT_DIR}/Wgs180_auto_qc_final.vcf"

# QC Parameters
MAX_MISSING=0.5
HWE_THRESHOLD=0.0001
MAF_THRESHOLD=0.05
mkdir -p ${OUTPUT_DIR}


# ==========================================
# 2. Extract Autosomes
# ==========================================
echo "[Step 1] Extracting Autosomes (Removing chrX and chrY)..."
${BCFTOOLS} view \
    -i 'CHROM!="chrX" && CHROM!="chrY"' \
    -Oz \
    -o ${AUTO_VCF} \
    ${INPUT_VCF} \
    --threads 4
# Index the autosomal VCF
${BCFTOOLS} index -t ${AUTO_VCF}
# Count variants before filtering
COUNT_AUTO=$(${BCFTOOLS} view -H ${AUTO_VCF} | wc -l)
echo " -> Autosomal variants extracted: ${COUNT_AUTO}"


# ==========================================
# 3. Apply QC Filters
# ==========================================
echo "[Step 2] Applying QC Filters..."
${VCFTOOLS} \
    --gzvcf ${AUTO_VCF} \
    --max-missing 0.5 \
    --hwe 0.0001 \
    --maf 0.05 \
    --recode --recode-INFO-all \
    --stdout > ${FINAL_QC_VCF}
COUNT_FINAL=$(grep -v "^#" ${FINAL_QC_VCF} | wc -l)

echo "QC Analysis Finished."
echo "Input Variants:   ${COUNT_AUTO} (Autosomes)"
echo "Final Variants:   ${COUNT_FINAL} (After QC)"
echo "Output File:      ${FINAL_QC_VCF}"
