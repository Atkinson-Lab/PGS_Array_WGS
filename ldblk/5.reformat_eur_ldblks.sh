#!/bin/bash

awk '
BEGIN {
  OFS="\t"  # Set output field separator to tab
}
NR == 1 { next }  # Skip the header line
{
  # Remove "chr" from the first column to create the fourth column
  fourth_column = substr($1, 4)
  
  # Track the count for each chromosome group
  if ($1 != prev_chrom) {
    group_count = 1  # Reset the group count for a new chromosome
  } else {
    group_count++  # Increment for the same chromosome group
  }

  # Store the current chromosome in prev_chrom
  prev_chrom = $1
  
  # Add the new fourth and fifth columns
  print $0, fourth_column, "blk_" group_count
}
' pyrho_EUR_LD_blocks.bed > pyrho_EUR_LD_blocks.txt
