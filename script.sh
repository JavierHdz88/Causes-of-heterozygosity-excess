# Author: Gustavo Ibrahim Giles (2021)
#https://orcid.org/0000-0001-8482-6253

### Populus

### Step 0.- Calculate missing data per individual (in vcftools)
vcftools --gzvcf Mexico.vcf.gz --missing-indv
# When running this command, two files will be generated. We are going to read in R the file out.imiss (Step 1 in the file analisis.r)

### Eliminate individuals with high percentage (greater than 20%) of missing data 
vcftools --gzvcf Mexico.vcf.gz --remove List_IndvHigMiss.txt --remove-indels --recode --recode-INFO-all --out Mexico1

### Calculate for this new database, quality parameters of the new assembly
vcftools --vcf Mexico1.recode.vcf --missing-site    # For missing data
vcftools --vcf Mexico1.recode.vcf --site-mean-depth # For average sequencing depth per site
vcftools --vcf Mexico1.recode.vcf --freq            # For frequency of the derived allele
sed -i -e 's/\w://g' out.frq                        # It is simply to modify the file so that we can read it in R
vcftools --gzvcf Mexico1.recode.vcf --hardy         # For excess heterozygos

#If we open the out.freq file in Excel, you will notice that the last column has no name. That column corresponds (or at least it should) to the frequency of the derived allele for that SNP. Rename those two columns to FREQ1 and FREQdev and save the changes

# Now yes, let's go to STEP 4, which is in the file analisis.r