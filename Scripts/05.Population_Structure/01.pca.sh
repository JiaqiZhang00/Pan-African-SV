#!/bin/bash

# ==============================================================================
# Script: 01.pca.sh
# Description: PCA using EIGENSOFT smartpca.
# Tools: PLINK v1.90, EIGENSOFT (smartpca)
# ==============================================================================

# ==========================================
# 1. Configuration
# ==========================================
# Tools
PLINK="plink"
SMARTPCA="smartpca"

# Input Configuration
INPUT_VCF="Wgs180_auto_missing_hwe_100kb.vcf"
# Population Map File
POP_INFO_FILE="wgs180_pop.txt" # Format: SampleID  Population (No header)
# Output Configuration
OUTPUT_DIR="./pca_output"
PREFIX="wgs180_pca"

mkdir -p ${OUTPUT_DIR}


# ==========================================
# 2. Convert VCF to PLINK BED
# ==========================================
echo "[Step 1] Converting VCF to PLINK format..."
${PLINK} \
    --vcf ${INPUT_VCF} \
    --make-bed \
    --double-id \
    --allow-extra-chr \
    --out ${OUTPUT_DIR}/${PREFIX}


# ==========================================
# 3. Prepare EIGENSOFT Input Files (.ind & .bim)
# ==========================================
echo "[Step 2] Formatting input files for smartpca..."
echo " Generating ${PREFIX}.ind..."
awk 'NR==FNR{pop[$1]=$2; next} {
    if ($2 in pop) 
        print $2, "U", pop[$2];
    else 
        print $2, "U", "Unknown";
}' ${POP_INFO_FILE} ${OUTPUT_DIR}/${PREFIX}.fam > ${OUTPUT_DIR}/${PREFIX}.ind

echo " Formatting ${PREFIX}.bim for EIGENSOFT compatibility..."
cp ${OUTPUT_DIR}/${PREFIX}.bim ${OUTPUT_DIR}/${PREFIX}.bim.bak
cat ${OUTPUT_DIR}/${PREFIX}.bim.bak | awk -v OFS='\t' '{
    split($5,a,""); 
    split($6,b,"");
    if(a[1]=="A"){print $1,$2,$3,$4,a[1],"C"}
    else if(a[1]=="G"){print $1,$2,$3,$4,a[1],"T"} 
    else if(a[1]=="C"){print $1,$2,$3,$4,a[1],"A"} 
    else if(a[1]=="T"){print $1,$2,$3,$4,a[1],"G"}
    else {print $0} # Fallback for others
}' > ${OUTPUT_DIR}/${PREFIX}.bim


# ==========================================
# 4. Generate Parameter File (smartpca.par)
# ==========================================
echo "[Step 3] Generating smartpca parameter file..."
cat <<EOF > smartpca.par
genotypename: ${OUTPUT_DIR}/${PREFIX}.bed
snpname:      ${OUTPUT_DIR}/${PREFIX}.bim
indivname:    ${OUTPUT_DIR}/${PREFIX}.ind
evecoutname:  ${OUTPUT_DIR}/${PREFIX}.evec
evaloutname:  ${OUTPUT_DIR}/${PREFIX}.eval
numoutevec:   4
numoutlieriter: 0
EOF


# ==========================================
# 5. Run smartpca
# ==========================================
echo "[Step 4] Running smartpca..."
${SMARTPCA} -p smartpca.par > smartpca.log
