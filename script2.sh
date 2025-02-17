#! /bin/sh

# Author: Gustavo Ibrahim Giles (2021)
#https://orcid.org/0000-0001-8482-6253

# With the command lines that you ran earlier in vcftools, you figured out what are the features that we have to look at in a vcf file, and how you can look at some of those features in R
# Once we define what are the parameters that best fit our data (minDP, max-missing, etc), we can make our filters through scripts (which are plain text files like this one you are reading, that you can open and edit from notepad or other programs like sublime text).

# The command on line 11 will perform a filter in vcftools that will eliminate those SNPs that are fixed in the dataset or that occur only once, out of a total of 1,312 times that can occur 
vcftools --gzvcf Mexico.vcf.gz --remove-indels --mac 2 --recode --recode-INFO-all --out Mexico1
#vcftools --vcf Mexico1.recode.vcf --missing-indv
vcftools --vcf Mexico1.recode.vcf --remove IndvHigMiss.txt --remove-indels --recode --recode-INFO-all --out Mexico1a
vcftools --vcf Mexico1a.recode.vcf --remove IndvHighMiss2.txt --max-missing 0.85 --minDP 10 --exclude-positions putative_misalign.txt --recode --recode-INFO-all --out Mexico2_mmiss85_mac2_minDP10
vcftools --vcf Mexico2_mmiss85_mac2_minDP10.recode.vcf --missing-indv

# Lines 12, 14, 15, and 16 contain the tasks we want to perform in vcftools to obtain a filtered vcf file.
# Notice that line 13 starts with a cat symbol (#). Whenever I use # at the beginning of a line (except for #! /bin/sh), I am telling the computer that this line should be ignored.
# The # symbols are very useful to make comments to help us remember what we are doing (for example see line 11).
# In order for this (and any other script) to execute our instructions, the first thing you have to do is:
# 1.- Make sure that the files Mexico.vcf.gz, IndvHigMiss.txt, IndvHighMiss2.txt, putative_misalign.txt and script2.sh (i.e., the script itself) are in the same folder.
# In the terminal, being in the folder with the files, write the following: chmod u+x script2.sh (with that, we are giving the permissions to the computer, so that it reads the script).  
# 3.- In the terminal, being in the folder with the files, type the following: ./script2.sh

# Let's go back to the filters. When you run this script, the file that we are going to put in R is going to be called Mexico2_mmiss85_mac2_minDP10.recode.vcf
# NOTICE that I changed a few things from the ones you ran previously. The main change I made was to use --mac instead of --maf
# Mac, unlike maf, uses count data.
# If for 5 diploid individuals we have A, A, A, A, A, A, A, A, A, A, T, T, the MAC (minor allele count) is going to be 2.
# In the same example, the MAF (minor allele frequency) would be 0.20
# In the same example, now suppose we have A, Na, A, A, A, Na, A, A, A, A, A, T, T. Mac will be equal to 2, but this time, Maf, will be equal to 0.25
# That means that MAF, being a frequency estimate, is going to be strongly affected by the missing data in the vcf (the Na).
# And for that reason, I recommend you to work with MAC, always balancing with sequencing depth (--minDP).

# I consider that the file Mexico2_mmiss85_mac2_minDP10.recode.vcf is ready to start measuring genetic diversity, 
# However, if you check the out.imiss file (which will also appear in your folder when the script finishes running) in R, you will see that some individuals still have a high frequency of missing data (at least 11 individuals have more than 40% missing data). 
# For now, I think this is fine, although it is always important to keep this in mind when interpreting the results. 
# If you try to eliminate those individuals with more than 40% missing data, you will see that the number of SNPs you recover will be higher. It will be up to you to make a balance between how many individuals and how many SNPs you want to recover.

# If you get the file Mexico2_mmiss85_mac2_minDP10.recode.vcf, it means you finished your first task and we can move on to R.
# Please try to install the following packages in R: vcfR, adegenet, pegas, and hierfstat








