#!/bin/bash
# ==============================================================================
# Script Name: 01.paragraph_genotyping.sh
# Description: SV Genotyping using Paragraph on SRS data.
# Tools used: Paragraph (multigrmpy.py), BCFtools
# ==============================================================================

# ==========================================
# 1. Configuration & Variables
# ==========================================
# Tools
PARAGRAPH_BIN="/path/to/paragraph/bin/multigrmpy.py"
PYTHON_BIN="python3" 
BCFTOOLS="bcftools"
# Resources
REF_GENOME="/path/to/reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
# Input Files
# The raw merged SV callset from Sniffles (Population level)
RAW_PAN_SV_VCF="pan_african_population.vcf.gz"
# Sample Configuration
# 'sample_manifest.txt' should contain: "SampleID  /path/to/sample.bam"
SAMPLE_MANIFEST="./sample_txt/${SAMPLE_ID}.txt"
# Output Configuration
OUTPUT_DIR="./genotyping_output/${SAMPLE_ID}"
FILTERED_REF_VCF="pan_african_sv_filtered_for_paragraph.vcf"
# Parameters
THREADS=16
MAX_READS=600  # -M parameter in Paragraph
mkdir -p ${OUTPUT_DIR}

# ==========================================
# 2. Reference VCF Filtering (Pre-processing)
# ==========================================
# Logic: Filter the Pan-SV dataset BEFORE genotyping to remove complex/large events
# that Paragraph handles poorly.
# Criteria:
# 1. Keep only 'PASS' filter variants.
# 2. Exclude TRA (Translocations).
# 3. Exclude INV (Inversions) > 5000 bp.
# 4. Exclude DUP (Duplications) > 5000 bp.
echo "[Step 1] Filtering Reference SV dataset for Paragraph..."
if [ ! -f "${FILTERED_REF_VCF}" ]; then
    ${BCFTOOLS} view -f PASS ${RAW_PAN_SV_VCF} | \
    ${BCFTOOLS} filter \
        -e 'SVTYPE="TRA" || (SVTYPE="INV" && SVLEN>5000) || (SVTYPE="DUP" && SVLEN>5000) || (SVTYPE="INV" && SVLEN<-5000) || (SVTYPE="DUP" && SVLEN<-5000)' \
        -o ${FILTERED_REF_VCF}
    
    echo "Filtered VCF generated: ${FILTERED_REF_VCF}"
else
    echo "Filtered VCF already exists. Skipping filtering step."
fi

# ==========================================
# 3. Running Paragraph (Genotyping)
# ==========================================
echo "[Step 2] Running Paragraph (multigrmpy) for ${SAMPLE_ID}..."
${PYTHON_BIN} ${PARAGRAPH_BIN} \
    -i ${FILTERED_REF_VCF} \
    -m ${SAMPLE_MANIFEST} \
    -M ${MAX_READS} \
    -o ${OUTPUT_DIR} \
    -r ${REF_GENOME} \
    -t ${THREADS}
