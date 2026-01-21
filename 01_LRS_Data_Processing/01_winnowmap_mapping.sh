#!/bin/bash

# Script Name: 01_winnowmap_mapping.sh
# Description: Long-read mapping using Winnowmap and BAM processing with SAMtools
# Paper Reference: "Long-read sequencing reveals a pan-African structural variation landscape driving phenotypic diversity and local adaptation ."
# Tools used: Winnowmap v2.03, SAMtools v1.7

# ==========================================
# 1. Configuration & Variables
# ==========================================
# Tool paths (Please adjust these paths to your environment)
WINNOWMAP="winnowmap"
SAMTOOLS="samtools"
MERYL="meryl"
PANDEPTH="pandepth"
# Resources
REF_GENOME="/path/to/reference/GRCh38_autosomes.fa" # GRCh38 autosomes only 
MERYL_DB="/path/to/meryl_db/GRCh38_k15.meryl"        # Pre-computed high-frequency k-mers (k=15) 
# Sample Configuration
SAMPLE_ID="Sample_ID"
# Input data: Space-separated list of fastq/fasta files
INPUT_DATA="/path/to/data/read1.fa.gz /path/to/data/read2.fa.gz"
# Output Configuration
OUTPUT_DIR="./${SAMPLE_ID}_bam"
OUT_PREFIX="${SAMPLE_ID}_aligned"
THREADS=24
# Create output directory
mkdir -p ${OUTPUT_DIR}


# ==========================================
# 2. Pipeline Execution
# ==========================================
echo "Starting pipeline for ${SAMPLE_ID}..."
START_TIME=$(date +'%Y-%m-%d %H:%M:%S')
# Step 1: Mapping reads to reference using Winnowmap 
# Note: '-ax map-pb' is used for PacBio CLR data as described in the methods.
echo "Step 1: Running Winnowmap mapping..."
${WINNOWMAP} -W ${MERYL_DB} -ax map-pb -t ${THREADS} ${REF_GENOME} ${INPUT_DATA} | \
${SAMTOOLS} view -bS -@ ${THREADS} > ${OUTPUT_DIR}/${OUT_PREFIX}.bam
# Step 2: Sorting BAM file 
echo "Step 2: Sorting BAM file..."
${SAMTOOLS} sort -@ ${THREADS} -o ${OUTPUT_DIR}/${OUT_PREFIX}.sorted.bam ${OUTPUT_DIR}/${OUT_PREFIX}.bam
# Step 3: Indexing sorted BAM file 
echo "Step 3: Indexing BAM file..."
${SAMTOOLS} index -@ ${THREADS} ${OUTPUT_DIR}/${OUT_PREFIX}.sorted.bam


# ==========================================
# 3. Cleanup & Logging
# ==========================================
# Check output and remove temporary unsorted BAM
ls -lh ${OUTPUT_DIR}/${OUT_PREFIX}.sorted.bam
if [ -f "${OUTPUT_DIR}/${OUT_PREFIX}.sorted.bam" ]; then
    echo "Sorting successful. Removing temporary unsorted BAM..."
    rm ${OUTPUT_DIR}/${OUT_PREFIX}.bam
fi
END_TIME=$(date +'%Y-%m-%d %H:%M:%S')
# Convert start and end times to seconds for duration calculation
START_SECONDS=$(date --date="$START_TIME" +%s)
END_SECONDS=$(date --date="$END_TIME" +%s)
DURATION=$((END_SECONDS - START_SECONDS))


echo "Pipeline finished."
echo "Start Time: ${START_TIME}"
echo "End Time:   ${END_TIME}"
echo "Total Duration: ${DURATION} seconds"
