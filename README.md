# poolseq_tools
A one-stop, reproducible environment for Pool-seq population-genomics workflows

This image bundles the software you typically need to take pooled-DNA Illumina reads all the way from raw FASTQ files to population-genetic and environmental-association results—without the pain of compiling each dependency by hand.
It is built on rocker/tidyverse:4.3.2, so you immediately get:

    Ubuntu 22.04 + GNU build chain

    R 4.3.2 with the tidyverse pre-installed

    Python 3 (venv & pip ready)

    RStudio-Server (port 8787, user rstudio / pwd rstudio) for an IDE-like experience

What’s inside? (grouped by purpose)
Category	Key tools & libraries (version implied by the Dockerfile)
1. Quality control & read trimming	FastQC · MultiQC · fastp · Trimmomatic · ea-utils (fastq-mcf) · FLASH · Seqtk
2. Read alignment & BAM handling	BWA-MEM2 · Bowtie2 · Minimap2 · Samtools · Bamtools · Bedtools · Picard · Mosdepth · Qualimap
3. Variant calling & VCF utilities	FreeBayes · GATK 4 · VarScan 2 · BCFtools · HTSlib · VCFtools · Pixy
4. Pool-seq & population-genomics analysis	PoPoolation2 · BayPass 2.4 · BayEnv2 · BayeScan 2.1 · PLINK 1.9/2.0 · TreeMix · MSMC2 · fastsimcoal2 · DIYABC · bam-readcount
5. R / Bioconductor ecosystem	Rsamtools · GenomicFeatures · GenomicRanges · rtracklayer · SNPRelate · ggtree · LEA · NOISeq · Repitools · qvalue · geneplotter & more
6. General utilities	GNU parallel · Git · wget/curl · vim/nano/less/tree · gdal/proj (for GIS-aware R packages)

(All executables are on the $PATH; most third-party JARs—GATK, DeDup, etc.—are symlinked into /usr/local/bin for convenience.)
