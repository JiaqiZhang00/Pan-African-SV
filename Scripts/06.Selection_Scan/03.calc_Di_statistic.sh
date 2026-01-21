#!/bin/bash
# ==============================================================================
# Script: 03.calc_Di_statistic.sh
# Description: Calculate Di statistic using a custom Perl script and Extract the top 1% outliers as candidate positive selection SVs.
# Tools: Perl, Python3
# ==============================================================================


# ==========================================
# 1. Configuration
# ==========================================
# Tools
PERL="perl"
PYTHON="python3"

# Scripts
DI_SCRIPT="./Di.pl"
FILTER_SCRIPT="./filter_top_percent.py"

# Inputs
FST_DIR="./fst_output"
# Populations List
POPS="RHG Amhara Chabu Dizi Hadza Herero Ju Fulani Mursi Sandawe Tikari Xoo"
# Output Configuration
OUTPUT_DIR="./di_output"
# Subfolder for top 1% results
TOP_DIR="${OUTPUT_DIR}/top_0.01"
# Parameters
PERCENTAGE=0.01  # Top 1%

mkdir -p ${OUTPUT_DIR}
mkdir -p ${TOP_DIR}


# ==========================================
# 2. Main Loop: Calculate Di & Filter
# ==========================================
for pop in ${POPS}; do
    echo "========================================"
    echo "Processing Population: ${pop}"
    DI_OUTPUT="${OUTPUT_DIR}/${pop}.Di.txt"
    TOP_OUTPUT="${TOP_DIR}/${pop}.Di.0.01.txt"
    # --- Step 1: Run Di.pl ---
    ${PERL} ${DI_SCRIPT} ${pop} ${FST_DIR}/*${pop}*.fst > ${DI_OUTPUT}
    
    # --- Step 2: Filter Top 1% ---
    if [ -s "${DI_OUTPUT}" ]; then
        echo " -> Extracting Top ${PERCENTAGE} (99th percentile)..."
        ${PYTHON} ${FILTER_SCRIPT} \
            ${DI_OUTPUT} \
            ${TOP_OUTPUT} \
            ${PERCENTAGE}
        echo "    Filtering done: ${TOP_OUTPUT}"
    else
        echo "    Warning: ${DI_OUTPUT} is empty or missing. Skipping filter."
    fi
done


echo "Pipeline Finished."
echo "Di Results:       ${OUTPUT_DIR}"
echo "Top 1% Candidates: ${TOP_DIR}"
