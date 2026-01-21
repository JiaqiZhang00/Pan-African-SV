#!/bin/bash
# ==============================================================================
# Script:  01.calc_pairwise_fst.sh
# Description: Calculate pairwise Fst between populations using VCFtools.
# Tools used: VCFtools
# ==============================================================================


# ==========================================
# 1. Configuration & Variables
# ==========================================
# Tools
VCFTOOLS="vcftools"
# Input Configuration
INPUT_VCF="Wgs180_auto_missing_hwe.vcf"  ###Note: Using the filtered dataset (missing filtered and HWE)
# Comparison List File
INPUT_PAIRS="input_pairs.txt"
# Output Configuration
OUTPUT_DIR="./fst_output"
mkdir -p ${OUTPUT_DIR}


# ==========================================
# 2. Execution Loop
# ==========================================
echo "Starting Fst Calculation..."
START_TIME=$(date +%s)
while read line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    files=(${line//,/ })
    file1=${files[0]}
    file2=${files[1]}
    pop1=$(basename "$file1" .txt)
    pop2=$(basename "$file2" .txt)
    OUT_PREFIX="${OUTPUT_DIR}/${pop1}_vs_${pop2}"
    echo "Processing: ${pop1} vs ${pop2}..."
    ${VCFTOOLS} \
        --vcf ${INPUT_VCF} \
        --weir-fst-pop ${file1} \
        --weir-fst-pop ${file2} \
        --out ${OUT_PREFIX}
done < ${INPUT_PAIRS}


# ==========================================
# 3. Formatting Output
# ==========================================
echo "Formatting results..."
for fst_file in ${OUTPUT_DIR}/*.weir.fst; do
    [ -e "$fst_file" ] || continue
    base_name="${fst_file%.weir.fst}"
    cat ${fst_file} | \
    awk 'NR>1 {print $1"_"$2"_"NR, $1, $2, $3, NR}' > ${base_name}.fst.formatted
    rm ${fst_file}
    echo "Formatted: ${base_name}.fst.formatted"
done


echo "Job Finished."
echo "Results stored in: ${OUTPUT_DIR}"
