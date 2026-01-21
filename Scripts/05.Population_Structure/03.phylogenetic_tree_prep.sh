#!/bin/bash

# ==============================================================================
# Script: 03.phylogenetic_tree_prep.sh
# Description: Phylogenetic tree construction using IQ-TREE.
# Tools: Python (pandas, numpy), vcf2phylip.py
# ==============================================================================

# ==========================================
# 1. Configuration
# ==========================================
# Tools
PYTHON="python"

# Path to vcf2phylip.py script
# download from: https://github.com/edgardomortiz/vcf2phylip
VCF2PHYLIP_SCRIPT="./vcf2phylip.py"

# Input Configuration
INPUT_VCF="Wgs180_auto_missing_hwe_100kb.vcf"
# Output Configuration
OUTPUT_DIR="./tree_prep_output"
INTERMEDIATE_VCF="${OUTPUT_DIR}/calls_maf_forced.vcf"
OUTPUT_PREFIX="180_wgs_maf"
mkdir -p ${OUTPUT_DIR}

# ==========================================
# 2. Format VCF (Force Ref/Alt to G/C)
# ==========================================
echo "[Step 1] Formatting VCF: Forcing REF/ALT to G/C..."
cat ${INPUT_VCF} | \
awk '/#/{print} !/#/{printf "%d\t%d\t%s\tG\tC\t", $1,$2,$3; for(i=6;i<=NF;i++){printf "%s\t",$i} printf "\n"}' | \
perl -npe "s/\t$//g" > ${INTERMEDIATE_VCF}


# ==========================================
# 3. Run vcf2phylip
# ==========================================
echo "[Step 2] Converting VCF to PHYLIP format..."
${PYTHON} ${VCF2PHYLIP_SCRIPT} \
    -i ${INTERMEDIATE_VCF} \
    --output-prefix ${OUTPUT_DIR}/${OUTPUT_PREFIX}


# ==========================================
# 5. Completion & Downstream Instructions
# ==========================================
FINAL_PHY="${OUTPUT_DIR}/${OUTPUT_PREFIX}.min4.phy"


echo "Preparation Finished."
echo "Output PHYLIP file: ${FINAL_PHY}"
#Downstream Analysis Note: We constructed the phylogenetic tree using the neighbor-joining method in MEGA (version 11), and evaluated the robustness of the phylogeny using 100 bootstraps.
#The results of MEGA were visualized using iTOL.
