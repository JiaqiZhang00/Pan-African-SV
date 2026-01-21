#!/bin/bash

# ==============================================================================
# Script: 02.admixture.sh
# Description: Population structure analysis using ADMIXTURE.
# Tools: PLINK v1.90, ADMIXTURE v1.3.0
# ==============================================================================


# ==========================================
# 1. Configuration & Variables
# ==========================================
# Tools
PLINK="plink"
ADMIXTURE="admixture"
# Input Configuration
INPUT_VCF="Wgs180_auto_missing_hwe_100kb.vcf"
# Output Configuration
OUTPUT_DIR="./admixture_output"
PLINK_PREFIX="wgs180_admix_input"

# Parameters
THREADS=8          
START_K=2
END_K=12
REPLICATES=10 

mkdir -p ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}/logs
mkdir -p ${OUTPUT_DIR}/results

# ==========================================
# 2. Convert VCF to PLINK BED
# ==========================================
echo "[Step 1] Converting VCF to PLINK binary format..."
# --geno 0.999: Although QC was done, this ensures ADMIXTURE compatibility
# --double-id: Use sample ID for both Family and Individual ID
${PLINK} \
    --vcf ${INPUT_VCF} \
    --make-bed \
    --geno 0.999 \
    --out ${OUTPUT_DIR}/${PLINK_PREFIX} \
    --double-id \
    --allow-extra-chr
BED_FILE="${OUTPUT_DIR}/${PLINK_PREFIX}.bed"


# ==========================================
# 3. Run ADMIXTURE Loop
# ==========================================
echo "[Step 2] Running ADMIXTURE (K=${START_K} to ${END_K}, ${REPLICATES} replicates)..."
cd ${OUTPUT_DIR}
for K in $(seq ${START_K} ${END_K}); do
    for r in $(seq 1 ${REPLICATES}); do
        echo " -> Processing K=${K} | Replicate=${r} ..."
        # Define log filename
        LOG_FILE="logs/log_K${K}_r${r}.out"
        # Run ADMIXTURE
        ${ADMIXTURE} \
            -s ${RANDOM} \
            --cv \
            -j${THREADS} \
            ${PLINK_PREFIX}.bed ${K} > ${LOG_FILE}
        
        # Move outputs (.Q and .P files) to results folder and rename
        if [ -f "${PLINK_PREFIX}.${K}.Q" ]; then
            mv "${PLINK_PREFIX}.${K}.Q" "results/${PLINK_PREFIX}.K${K}.r${r}.Q"
            mv "${PLINK_PREFIX}.${K}.P" "results/${PLINK_PREFIX}.K${K}.r${r}.P"
        else
            echo "Warning: Output for K=${K} r=${r} not generated."
        fi
    done
done


# ==========================================
# 4. Summarize Results & Find Best K
# ==========================================
echo "[Step 3] Summarizing CV Errors and Identifying Best Runs..."
SUMMARY_FILE="cv_error_summary.txt"
BEST_RUNS_FILE="best_runs_per_K.txt"

# Header
echo -e "K\tReplicate\tCV_Error" > ${SUMMARY_FILE}
echo -e "K\tBest_Replicate\tLowest_CV_Error\tBest_Q_File" > ${BEST_RUNS_FILE}

# Parse logs
grep "CV error" logs/*.out | \
    sed 's/logs\/log_K//g' | \
    sed 's/_r/\t/g' | \
    sed 's/.out:CV error (K=/\t/g' | \
    sed 's/): /\t/g' | \
    awk '{print $1, $2, $4}' | \
    sort -n -k1,1 -k3,3n >> ${SUMMARY_FILE}

# Find best run for each K
for K in $(seq ${START_K} ${END_K}); do
    # Sort by Error (column 3) and take the top 1
    BEST_RUN=$(awk -v k="$K" '$1 == k {print $0}' ${SUMMARY_FILE} | sort -k3,3n | head -n 1)
    if [ ! -z "$BEST_RUN" ]; then
        BEST_R=$(echo $BEST_RUN | awk '{print $2}')
        BEST_ERR=$(echo $BEST_RUN | awk '{print $3}')
        Q_FILE="results/${PLINK_PREFIX}.K${K}.r${BEST_R}.Q"
        echo -e "${K}\t${BEST_R}\t${BEST_ERR}\t${Q_FILE}" >> ${BEST_RUNS_FILE}
    fi
done


echo "Analysis Finished."
echo "Full CV Summary:      ${OUTPUT_DIR}/${SUMMARY_FILE}"
echo "Best Runs List:       ${OUTPUT_DIR}/${BEST_RUNS_FILE}"
echo "Admixture Results:    ${OUTPUT_DIR}/results/"
