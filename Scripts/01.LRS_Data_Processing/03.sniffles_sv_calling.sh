#!/bin/bash

# Script Name: 03.sniffles_sv_calling.sh
# Description: Structural Variant calling using Sniffles2 (Single Sample & Population Mode guidelines)
# Paper Reference: "Long-read sequencing reveals a pan-African structural variation landscape driving phenotypic diversity and local adaptation"
# Tools used: Sniffles2 v2.0.7

# ==========================================
# 1. Configuration & Variables
# ==========================================
# Tool paths
SNIFFLES="sniffles"

# Resources
# Reference genome (GRCh38)
REF_GENOME="/path/to/reference/hg38_22_XYM.fa"
# Tandem Repeat Finder annotation (TRF) for accurate calling in repetitive regions
TRF_BED="/path/to/annotation/human_GRCh38_no_alt_analysis_set.trf.bed"

# Sample Configuration
SAMPLE_ID="Sample_ID"

# Input Configuration
# Expects the sorted BAM file from step 01
INPUT_BAM="./${SAMPLE_ID}_bam/${SAMPLE_ID}_aligned.sorted.bam"

# Output Configuration
OUTPUT_DIR="./${SAMPLE_ID}_sv"
SNF_FILE="${OUTPUT_DIR}/${SAMPLE_ID}.snf"
VCF_FILE="${OUTPUT_DIR}/${SAMPLE_ID}.vcf.gz"

# Sniffles Parameters
THREADS=8
MIN_SUPPORT=10
MIN_SV_LEN=50
MAX_DEL_LEN=1000000

# Create output directory
mkdir -p ${OUTPUT_DIR}

# ==========================================
# 2. Pipeline Execution (Single Sample)
# ==========================================
echo "Starting SV calling for ${SAMPLE_ID}..."
START_TIME=$(date +'%Y-%m-%d %H:%M:%S')

# Step: Single Sample SV Calling (Generate SNF and VCF)
# Description: Calls SVs for a single individual and stores information in SNF format for later population merging.
echo "Step 1: Running Sniffles (Single Sample Mode)..."
${SNIFFLES} \
    --input ${INPUT_BAM} \
    --snf ${SNF_FILE} \
    --vcf ${VCF_FILE} \
    --reference ${REF_GENOME} \
    --tandem-repeats ${TRF_BED} \
    --minsupport ${MIN_SUPPORT} \
    --minsvlen ${MIN_SV_LEN} \
    --max-del-seq-len ${MAX_DEL_LEN} \
    --output-rnames \
    --sample-id ${SAMPLE_ID} \
    --threads ${THREADS}

# ==========================================
# 3. Population Calling
# ==========================================
# NOTE: The following step should be run ONLY once, after all individual samples have been processed.
# Create a list of all .snf files and run:
echo "Step 2: Population Mode"
${SNIFFLES} \
   --input snf_file_list.tsv \
   --vcf pan_african_population.vcf.gz \
   --reference ${REF_GENOME} \
   --tandem-repeats ${TRF_BED} \
   --threads ${THREADS}

# ==========================================
# 4. Logging & Completion
# ==========================================
END_TIME=$(date +'%Y-%m-%d %H:%M:%S')

# Convert start and end times to seconds for duration calculation
START_SECONDS=$(date --date="$START_TIME" +%s)
END_SECONDS=$(date --date="$END_TIME" +%s)
DURATION=$((END_SECONDS - START_SECONDS))

echo "Pipeline finished."
echo "Start Time: ${START_TIME}"
echo "End Time:   ${END_TIME}"
echo "Total Duration: ${DURATION} seconds"
