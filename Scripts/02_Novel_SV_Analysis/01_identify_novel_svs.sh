#!/bin/bash

# ==============================================================================
# Script Name: 01_identify_novel_svs.sh
# Description: Identify novel SVs by comparing against public SV databases.
# Paper Reference: "Long-read sequencing reveals a pan-African structural variation landscape driving phenotypic diversity and local adaptation"
# Tools used: BEDTools (v2.30.0)
# Input Format Requirement:
#   Input BED must be standard BED format with at least 6 columns:
#   Col 1-3: chrom, start, end
#   Col 4:   SV Type (must match database types, e.g., INS, DEL, INV, DUP, TRA)
#   Col 5:   SV Length (Critical for normalizing Insertions)
# ==============================================================================

# ==========================================
# 1. Configuration & Variables
# ==========================================
# Tools
BEDTOOLS="bedtools"
# Input Study File
STUDY_SVS="RHG_uniq_pos.bed"
# Comparison Databases
DB_GNOMAD="./databases/gnomad_v4.1_sv.bed"
DB_AUDANO="./databases/audano_2019_sv.bed"
DB_HGSVC="./databases/hgsvc2_sv.bed"
DB_DBVAR="./databases/dbvar_nonredundant_sv.bed"
DB_1kGP="./databases/1kGP_ONT_sv.bed"
# Create a list for looping
DATABASES=(
    "$DB_GNOMAD"
    "$DB_AUDANO"
    "$DB_HGSVC"
    "$DB_DBVAR"
    "$DB_1kGP"
)

# Output Files
NORM_SVS="processed_study_svs_normalized.bed"
REPORTED_SVS_MERGED="all_reported_svs.bed"
FINAL_NOVEL_SVS="final_novel_svs.bed"

# ==========================================
# 2. Pre-processing & Normalization
# ==========================================
echo "[Step 1] Normalizing SV coordinates (Handling Insertions)..."
awk -F '\t' 'BEGIN{OFS="\t"} {
    if ($4 == "INS") {
        # Convert single-point insertion to interval: Start to Start + Length
        print $1, $2, $2 + $5, $4, $5, $6;
    } 
    else if ($4 == "BND") {
        print $1, $2, $3, "TRA", $5, $6;
    }
    else {
        print $0;
    }
}' "${STUDY_SVS}" > "${NORM_SVS}"
echo "Normalization complete. Output: ${NORM_SVS}"

# Initialize empty file for reported SVs
> "${REPORTED_SVS_MERGED}"

# ==========================================
# 3. Database Comparison Loop
# ==========================================
echo "[Step 2] Comparing against reference databases..."
for db in "${DATABASES[@]}"; do
    db_name=$(basename "$db")    
    echo " -> Processing database: $db_name"
    temp_intersect="temp_intersect_${db_name}.bed"
    ${BEDTOOLS} intersect \
        -a "${NORM_SVS}" \
        -b "${db}" \
        -wa -wb -r -f 0.5 > "${temp_intersect}"
    awk -F '\t' '$4 == $NF {print $1, $2, $3, $4, $5, $6}' "${temp_intersect}" >> "${REPORTED_SVS_MERGED}"
    rm "${temp_intersect}"
done

# ==========================================
# 4. Final Aggregation & Novel SV Identification
# ==========================================
echo "[Step 3] Generating final list of Novel SVs..."
# Sort and Uniq the merged reported list to remove duplicates
sort -k1,1V -k2,2n -k3,3n "${REPORTED_SVS_MERGED}" | uniq > "all_reported_unique.bed"
total_reported=$(wc -l < "all_reported_unique.bed")
echo "Total unique Reported SVs identified: ${total_reported}"

# Identify Novel SVs: 
${BEDTOOLS} subtract \
    -a "${NORM_SVS}" \
    -b "all_reported_unique.bed" \
    -A > "${FINAL_NOVEL_SVS}"

final_novel_count=$(wc -l < "${FINAL_NOVEL_SVS}")

echo "========================================================"
echo "Analysis Finished."
echo "Total Reported SVs found: ${total_reported}"
echo "Final Novel SVs count:    ${final_novel_count}"
echo "Output File:              ${FINAL_NOVEL_SVS}"
echo "========================================================"
