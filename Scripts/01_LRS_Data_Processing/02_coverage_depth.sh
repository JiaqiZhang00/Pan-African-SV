#!/bin/bash

# Script Name: 02_coverage_depth.sh
# Description: Calculate genome coverage depth for sorted BAM files using Pandepth
# Paper Reference: "Long-read sequencing reveals a pan-African structural variation landscape driving phenotypic diversity and local adaptation."
# Tools used: Pandepth v2.25

# ==========================================
# 1. Configuration & Variables
# ==========================================
# Tool paths
PANDEPTH="pandepth"
# Sample Configuration
SAMPLE_ID="Sample_ID"
# Input Configuration
INPUT_BAM="./${SAMPLE_ID}_bam/${SAMPLE_ID}_aligned.sorted.bam"
# Output Configuration
OUTPUT_DIR="./${SAMPLE_ID}_bam"
OUT_PREFIX="${SAMPLE_ID}_depth"
THREADS=24

# ==========================================
# 2. Pipeline Execution
# ==========================================
echo "Starting coverage calculation for ${SAMPLE_ID}..."
START_TIME=$(date +'%Y-%m-%d %H:%M:%S')

# Step: Calculate coverage using Pandepth
echo "Step 1: Running Pandepth..."
${PANDEPTH} -i ${INPUT_BAM} -o ${OUTPUT_DIR}/${OUT_PREFIX} -t ${THREADS}

# ==========================================
# 3. Logging & Completion
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
