# Author: Gustavo Ibrahim Giles (2021)
#https://orcid.org/0000-0001-8482-6253

#Step 1: Assess the amount of missing data for each individual
#First of all, let's check if the database contains individuals with a high percentage of missing data.
#This step is important because calculations and filters based on MAF and excess heterozygosity rely on the number of individuals in the database.
#So, individuals with a lot of missing data will bias our estimates.
#Now, let's export the table containing those values:
missInd<-read.table("out.imiss", sep = "\t", header = T)

# To know the distribution of missing data per individual:
summary(missInd$F_MISS) 
# From the above command we can see that 75% of the individuals (492 ind) have a missing data frequency of less than 0.12
# Let's see which individuals represent the 25% with the most missing data
IndvHigMiss<-missInd[missInd$F_MISS>0.11912,] 

#164 individuals have a missing data frequency greater than ~0.12
hist(IndvHigMiss$F_MISS) 
#The histogram shows that of these 164 individuals, the majority have a frequency of missing data of less than 0.2

# Let's be cool and discard in VCFTOOLS only those individuals that have a missing data frequency of less than 0.2. To do so, let's first make a list of these individuals
IndvHigMiss<-missInd[missInd$F_MISS>0.2,]

# Now there are 75 individuals. We are going to generate a table with those individuals, which will be used to delete them in VCFTOOLS, for the moment
write.table(IndvHigMiss, "IndvHigMiss.txt", sep = "\t", quote = F)
# If all goes well up to here, in your directory look for the file IndvHigMiss.txt
# You must open the file IndvHigMiss.txt and generate a new file, only with the names of the individuals.
# I named that new file List_IndvHigMiss.txt. We are going to use it for STEP TWO Vcftools
# Let's go back to the file called script.sh
### Paso 4.- Evaluar frecuencia del alelo derivado, profundidad de secuenciacion, exceso de heterocigosis y datos faltantes por sitio

# First, let's read all the tables that we generated in VCFTOOLS.
# Average sequencing depths per site 
depth<-read.table("out.ldepth.mean", sep="\t", header = T)
#(shallow depths= less certainty that this SNP is real)
#(very high depths= that SNP may be the result of the alignment of duplicated regions in the genome)

#Frequency of missing data per site (missing data)
miss<-read.table("out.lmiss", sep="\t", header = T)
#(A database with as little missing data as possible is preferred, although it is not mandatory to have no missing data)

#Frequency of the minor allele (or derivative, in the case of this database)
maf<-read.table("out.frq", sep="\t", header = T)
# Low-frequency derived alleles may be true variants or sequencing errors.
# If they are sequencing errors, these low frequency variants must have low sequencing depths.
# To eliminate these variants, we will look for sites with 1) a low minor allele frequency and 2) very low sequencing depths.

# HW equilibrium 
het<-read.table("out.hwe", sep="\t", header = T)
# HW will help us to detect sites showing excess heterozygosity (P<0.01)
# These sites with excess heterozygosity can arise from misalignment of duplicated regions in the genome
# To eliminate these variants, we will look for sites with 1) excess heterozygosity and 2) very high sequencing depths

# Let's create a table, only with the columns we are interested in (just to avoid getting bogged down with so many tables)Alldata<-cbind(depth[,c(1,2,3)], maf[,6], het[,8], miss[,6])
colnames(Alldata)<-c("chrom", "pos", "depth_prom", "freqAllDer", "ProbExcHet", "Miss")

# Let's look for sequencing errors. So we need to make a list of SNPs with:
# a) low derived allele frequency and b) low sequencing depth

# Let's see how the derived allele frequency is distributed
hist(Alldata$freqAllDer)
summary(Alldata$freqAllDer)
# Notice that most of them have a very low frequency. 
# Therefore, they may be sequencing errors.
# Let's make a list of those sites that fall, I don't know, in the first three quantiles.
# Remember that you can vary these values, as you see fit.

lowFreqAllDer<-Alldata[Alldata$freqAllDer<0.005172,]

# Let's see what the average sequencing depth is like for these loci
hist(lowFreqAllDer$depth_prom)
summary(lowFreqAllDer$depth_prom)
# See that 75% of the SNPs with low frequency alleles (<0.005172) have an average depth of no less than 20.417
# 25% of those sites have a depth of less than 7.17 and are therefore strong candidates for sequencing errors 
# Let's make a list of these SNPs
lowFreq_lowdepth<-lowFreqAllDer[lowFreqAllDer$depth_prom<7,]
# In total, there are 102448 low-frequency SNPs (present in at least 5 copies of the 1162 in the data) and with an average depth less than 7
# There are 1162 copies because we are analyzing 581 individuals, and each individual has two copies of their genetic material (assuming they are diploid)
# That's the reason why first of all, it is a good idea to eliminate individuals with a high percentage of missing data
# Because parameters such as MAF, average sequencing depth, etc, are calculated as a function of the number of individuals (rather, of copies)

# Only to evaluate the behavior of “sequencing errors” 

library(ggplot2)
scatterPlot <- ggplot(lowFreq_lowdepth,aes(freqAllDer,depth_prom, color=Miss)) + 
  geom_point() 
scatterPlot

# We are going to look for SNPs that are the result of the alignment of duplicated regions in the genome.
# For them, we need a) SNPs with an excess of heterozygies (according to Hardy Weinberg) and
# b) that have a high sequencing depth.

# First let's make a list of those with excess of heterozygies
Exc_Het<-Alldata[Alldata$ProbExcHet<0.01,]

# And now, let's check for those SNPs, what is their average sequencing depth
hist(Exc_Het$depth_prom)
summary(Exc_Het$depth_prom)
# The average depth of the sites with excess heterozygotes is 18,671 
# In this case, let's make a list with sites having an average depth greater than 23
# This list will contain our candidate SNPs for duplications

Exc_Het_HighDepth<-Exc_Het[Exc_Het$depth_prom>23,]#The list must contain the information of 1329 SNPs
# We are going to export this database, as we need this list to tell VCFTOOLS to delete those sites, specifically
write.table(Exc_Het_HighDepth, "putative_misalign.txt", sep="\t", quote = F)

# Let's see graphically how the data behave
scatterPlot <- ggplot(Exc_Het_HighDepth,aes(freqAllDer,depth_prom, color=Miss)) + 
  geom_point() 
scatterPlot

## 4.4 Missing data
## Finally, let's look at the frequency of missing data using a histogram
hist(Alldata$Miss)
summary(Alldata$Miss)
# See that 75% of the SNPs have a missing data frequency of less than 0.12
### We can be a bit permissive, in fact, and stay with SNPs that have a missing data frequency of less than 0.20

### From these analyses, we can be sure which filters we can use on our vcf file:
### You can try these combinations.
--maf 0.005 and --minDP 10
--maf 0.01 and --minDP 7


