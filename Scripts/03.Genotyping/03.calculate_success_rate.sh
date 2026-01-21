#!/bin/bash

# ==============================================================================
# Script Name: 03.calculate_success_rate.sh
# Input: The final merged VCF from 02.genotype_postprocessing.sh (merge_wgs180.vcf.gz)
# ==============================================================================

# ==========================================
# 1. Configuration
# ==========================================
INPUT_VCF="./final_callset/merge_wgs180.vcf.gz"
OUTPUT_DIR="./final_callset"
OUTPUT_FILE="${OUTPUT_DIR}/success_rate.txt"

# ==========================================
# 2. Execution
# ==========================================
echo "Starting Success Rate Calculation..."
echo "Input VCF: ${INPUT_VCF}"

#Step 1: Extract Sample Names from Header
echo "Extracting sample names..."
SAMPLES=$(zgrep -m 1 "^#CHROM" ${INPUT_VCF} | cut -f10-)

#Step 2: Calculate Success Rate using AWK
echo "Processing VCF records (this may take a moment)..."
zgrep -v "^#" ${INPUT_VCF} | awk -v samples="$SAMPLES" '
BEGIN { 
    OFS="\t"; 
    # Load sample names into an array
    split(samples, sample_names, "\t"); 
    print "Sample", "Success_Rate"
}
{
    # Iterate through genotype columns (starting from 10)
    for (i=10; i<=NF; i++) {
        total[i]++
        # Check for missing genotype "./." or "."
        if ($i ~ /^\.\/\./ || $i == ".") {
            missing[i]++
        }
    }
}
END {
    # Calculate and print result for each sample
    for (i=10; i<=NF; i++) {
        # Avoid division by zero if file is empty
        if (total[i] > 0) {
            success = (1 - (missing[i] / total[i])) * 100
        } else {
            success = 0
        }
        # Array index maps back to sample_names (i-9)
        print sample_names[i-9], success
    }
}' > ${OUTPUT_FILE}

echo "Calculation Finished."
echo "Success rate report: ${OUTPUT_FILE}"
