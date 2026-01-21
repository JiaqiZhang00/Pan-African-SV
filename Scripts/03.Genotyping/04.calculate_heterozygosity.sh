#!/bin/bash

# ==============================================================================
# Script Name: 04.calculate_heterozygosity.sh
# Description: Calculate heterozygosity for each individual using VCFtools.
# Tools: VCFtools v0.1.16
# ==============================================================================

# Tools
VCFTOOLS="vcftools"

# Input Configuration
INPUT_VCF="merge_wgs180.vcf.gz"

# Output Configuration
OUTPUT_PREFIX="pan_african_heterozygosity"

# Run VCFtools
${VCFTOOLS} \
    --gzvcf ${INPUT_VCF} \
    --het \
    --out ${OUTPUT_PREFIX}
    
echo "Calculation Finished."
echo "Result file: ${OUTPUT_DIR}/${OUTPUT_PREFIX}.het"
