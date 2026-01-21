#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script Name: generate_pairs.py
Description: Generates a list of pairwise population combinations for Fst analysis.
Output: 'input.file' containing comma-separated pairs (e.g., pop_Amhara,pop_Chabu).
"""

import itertools
import os
populations = [
    'pop_Amhara',
    'pop_Chabu',
    'pop_Dizi',
    'pop_Hadza',
    'pop_Herero',
    'pop_Fulani',
    'pop_Mursi',
    'pop_RHG',
    'pop_Sandawe',
    'pop_Tikari',
    'pop_San'
]
output_filename = 'input.file'

def main():
    with open(output_filename, 'w') as f:
        for pair in itertools.combinations(populations, 2):
            f.write(f"{pair[0]},{pair[1]}\n")

    print(f"Successfully generated '{output_filename}' with {len(list(itertools.combinations(populations, 2)))} pairs.")

if __name__ == "__main__":
    main()
