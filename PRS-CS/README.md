# PRS-CS
### The codes for running PRS-CS:

- `make_bim.sh`: Since PRS-CS requires a BIM file as an input, this script generates a BIM format file without using PLINK.
- `make_array_sst.sh` and  `make_wgs_sst.sh`: Scripts for generating summary statistics files in the format required by PRS-CS.
- `run_prs_cs_array.sh` and `run_prs_cs_wgs.sh`: Scripts for running the PRS-CS program.


***Important notes***

To run PRS-CS with the in-house whole-genome LD panel (see the `ldblk` directory), we modified the PRS-CS source code to point to our LD panel:

In `PRScs.py`, line 100, ~~`snpinfo_1kg_hm3`~~ was changed to `snpinfo_hgdp1kg_wgs`:

```
def main():
    param_dict = parse_param()

    for chrom in param_dict['chrom']:
        print('##### process chromosome %d #####' % int(chrom))

        if '1kg' in os.path.basename(param_dict['ref_dir']):
            ref_dict = parse_genet.parse_ref(param_dict['ref_dir'] + '/snpinfo_1kg_hm3', int(chrom))
        elif 'ukbb' in os.path.basename(param_dict['ref_dir']):
            ref_dict = parse_genet.parse_ref(param_dict['ref_dir'] + '/snpinfo_ukbb_hm3', int(chrom))

```
to 
```
def main():
    param_dict = parse_param()

    for chrom in param_dict['chrom']:
        print('##### process chromosome %d #####' % int(chrom))

        if '1kg' in os.path.basename(param_dict['ref_dir']):
            ref_dict = parse_genet.parse_ref(param_dict['ref_dir'] + '/snpinfo_hgdp1kg_wgs', int(chrom))
        elif 'ukbb' in os.path.basename(param_dict['ref_dir']):
            ref_dict = parse_genet.parse_ref(param_dict['ref_dir'] + '/snpinfo_ukbb_hm3', int(chrom))
```

In `parse_genet.py`, line 164, ~~`ldblk_1kg_chr`~~ was changed to `ldblk_hgdp1kg_chr`:

```
def parse_ldblk(ldblk_dir, sst_dict, chrom):
    print('... parse reference LD on chromosome %d ...' % chrom)

    if '1kg' in os.path.basename(ldblk_dir):
        chr_name = ldblk_dir + '/ldblk_1kg_chr' + str(chrom) + '.hdf5'
    elif 'ukbb' in os.path.basename(ldblk_dir):
        chr_name = ldblk_dir + '/ldblk_ukbb_chr' + str(chrom) + '.hdf5'
```
to
```
def parse_ldblk(ldblk_dir, sst_dict, chrom):
    print('... parse reference LD on chromosome %d ...' % chrom)

    if '1kg' in os.path.basename(ldblk_dir):
        chr_name = ldblk_dir + '/ldblk_hgdp1kg_chr' + str(chrom) + '.hdf5'
    elif 'ukbb' in os.path.basename(ldblk_dir):
        chr_name = ldblk_dir + '/ldblk_ukbb_chr' + str(chrom) + '.hdf5'
```


