#!/usr/bin/python

# File paths
snpinfo_file = "ldblk/hgdp1kg/hg38/all_snpinfo"
combined_snps_file = "ldblk/hgdp1kg/hg38/combined_ld_snps"
output_file = "ldblk/hgdp1kg/hg38/ldblk_hgdp1kg_eur_hg38/snpinfo_hgdp1kg_wgs_hg38"

# Load SNP IDs from combined_snps_file into a list (preserving the order)
with open(combined_snps_file) as f:
    snp_list = [line.strip() for line in f]

# Create a set for fast lookup
snp_set = set(snp_list)

# Process snpinfo file while keeping the header
with open(snpinfo_file) as fin, open(output_file, 'w') as fout:
    # Read and write the header line
    header = fin.readline()
    fout.write(header)

    # Write SNP info lines in the order defined by combined_snps_file
    snpinfo_lines = {line.split()[1]: line for line in fin}  # Map SNP to its full line in snpinfo_file

    # Write the lines in the order they appear in combined_snps_file
    for snp in snp_list:
        if snp in snpinfo_lines:
            fout.write(snpinfo_lines[snp])

print("Subset file saved to " + output_file + ".")
