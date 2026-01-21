#!/bin/bash
# ==============================================================================
# Script:  02.calc_pairwise_fst.sh
# Description: Calculate pairwise Fst between populations using VCFtools.
# Tools used: VCFtools， python3
# ==============================================================================


# ==========================================
# 1. Configuration
# ==========================================
# Tools
VCFTOOLS="vcftools"
# Input Configuration
INPUT_VCF="Wgs180_auto_missing_hwe.vcf"
# Python script to generate pairs
PAIR_LIST="input.file"
# Directory containing Population Sample ID files
POP_ID_DIR="./pop_ids"
# Output Configuration
OUTPUT_DIR="./fst_output"

mkdir -p ${OUTPUT_DIR}


# ==========================================
# 2. Step 1: Generate Pair List
# ==========================================
echo "[Step 1] Generating pairwise population list..."
python3 ./01.generate_pairs.py


# ==========================================
# 3. Step 2: Calculate Fst
# ==========================================
echo "[Step 2] Starting VCFtools Fst Calculation..."
while read line; do
    [[ -z "$line" ]] && continue
    IFS=',' read -r pop1 pop2 <<< "$line"
    file1="${POP_ID_DIR}/${pop1}"
    file2="${POP_ID_DIR}/${pop2}"
    if [ ! -f "$file1" ]; then
        if [ -f "${file1}.txt" ]; then file1="${file1}.txt"; else echo "Warning: Sample file for ${pop1} not found in ${POP_ID_DIR}. Skipping."; continue; fi
    fi
    if [ ! -f "$file2" ]; then
        if [ -f "${file2}.txt" ]; then file2="${file2}.txt"; else echo "Warning: Sample file for ${pop2} not found in ${POP_ID_DIR}. Skipping."; continue; fi
    fi
    OUT_PREFIX="${OUTPUT_DIR}/${pop1}_vs_${pop2}"
    echo " -> Processing: ${pop1} vs ${pop2}"
    ${VCFTOOLS} \
        --vcf ${INPUT_VCF} \
        --weir-fst-pop ${file1} \
        --weir-fst-pop ${file2} \
        --out ${OUT_PREFIX} \
        2>/dev/null  
done < ${PAIR_LIST}


# ==========================================
# 4. Step 3: Format Output
# ==========================================
echo "[Step 3] Formatting results (Adding Unique IDs)..."
count=0
for fst_file in ${OUTPUT_DIR}/*.weir.fst; do
    [ -e "$fst_file" ] || continue
    base_name="${fst_file%.weir.fst}"
    awk 'NR>1 {print $1"_"$2"_"NR, $1, $2, $3, NR}' ${fst_file} > ${base_name}.fst.formatted
    rm ${fst_file}
    ((count++))
done


echo "Fst Analysis Finished."
echo "Pairs Processed: ${count}"
echo "Results Directory: ${OUTPUT_DIR}"
