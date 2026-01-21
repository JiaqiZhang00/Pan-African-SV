#!/bin/bash

# ==============================================================================
# Script Name: 02.genotype_postprocessing.sh
# Description: Merge Paragraph genotypes, normalize ploidy, calculate Allele Frequency and compute Heterozygosity.
# Tools used: BCFtools v1.16, VCFtools v0.1.16
# ==============================================================================

# ==========================================
# 1. Configuration
# ==========================================
BCFTOOLS="bcftools"
VCFTOOLS="vcftools"
# Directories
GENOTYPE_DIR="./genotyping_output"
# Output Configuration
OUTPUT_DIR="./final_callset"
VCF_FILE_LIST="vcf_file_list.txt"
RAW_MERGED_VCF="temp_merged_raw.vcf.gz"
FINAL_VCF="merge_wgs180.vcf.gz"  
# Parameters
THREADS=24
mkdir -p ${OUTPUT_DIR}

# ==========================================
# 2. Preparation: Generate VCF List
# ==========================================
echo "[Step 1] Generating list of VCF files from ${GENOTYPE_DIR}..."
find ${GENOTYPE_DIR} -name "genotypes.vcf.gz" | sort > ${VCF_FILE_LIST}

# ==========================================
# 3. Population Merge
# ==========================================
echo "[Step 2] Merging samples into population VCF..."
${BCFTOOLS} merge \
    -m id \
    -Oz \
    -o ${OUTPUT_DIR}/${RAW_MERGED_VCF} \
    -l ${VCF_LIST} \
    --force-samples \
    --threads ${THREADS}
echo "Merge complete. Temporary file: ${OUTPUT_DIR}/${RAW_MERGED_VCF}"

# ==========================================
# 4. Post-Processing: FixPloidy & Fill-Tags
# ==========================================
# 1. fixploidy: Normalizes non-standard genotype fields (e.g. from Paragraph).
# 2. fill-tags: Calculates Allele Frequency.
echo "[Step 3] Applying FixPloidy and Calculating AF..."
${BCFTOOLS} +fixploidy ${OUTPUT_DIR}/${RAW_MERGED_VCF} | \
${BCFTOOLS} +fill-tags \
    --output-type z \
    --output ${OUTPUT_DIR}/${FINAL_VCF} \
    -- -t AF
# Index the final file
${BCFTOOLS} index ${OUTPUT_DIR}/${FINAL_VCF}
# Cleanup intermediate raw merge file
rm ${OUTPUT_DIR}/${RAW_MERGED_VCF}


echo "Pipeline Finished."
echo "Final VCF: ${OUTPUT_DIR}/${FINAL_VCF}"
