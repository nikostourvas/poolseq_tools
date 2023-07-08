####### Dockerfile #######
FROM rocker/tidyverse:4.3.0
MAINTAINER Nikolaos Tourvas <nikostourvas@gmail.com>

# Create directory for population genetics software on linux and use it as working dir
RUN mkdir /home/rstudio/software
WORKDIR /home/rstudio/software

# Prevent error messages from debconf about non-interactive frontend
ARG TERM=linux
ARG DEBIAN_FRONTEND=noninteractive

# Install ubuntu binaries
RUN apt update && apt -y install \
	vim \
	tree \
	time \
	parallel \
	default-jre \
	build-essential cmake autoconf automake \
	zlib1g-dev libbz2-dev liblzma-dev libtinfo5 \
	bwa \
	trimmomatic \
	fastqc \
	seqtk \
	picard-tools \
	bamtools \
	ea-utils \
	seqtk \
	plink plink1.9 plink2

# Install grenedalf
RUN git clone --recursive https://github.com/lczech/grenedalf.git \
	&& cd grenedalf \
	&& make \
	&& mv /home/rstudio/software/grenedalf/bin/grenedalf /usr/bin/grenedalf

# Install Baypass
RUN wget http://www1.montpellier.inra.fr/CBGP/software/baypass/files/baypass_2.4.tar.gz \
        && tar -zxvf baypass_2.4.tar.gz \
        && cd baypass_2.4/sources \
        && make clean all FC=gfortran \
        && make clean \
        && chmod +x g_baypass \
        && mv /home/rstudio/software/baypass_2.4/sources/g_baypass /usr/bin/g_baypass

# Install VarScan
RUN wget https://github.com/dkoboldt/varscan/releases/download/v2.4.6/VarScan.v2.4.6.jar \
	&& mv VarScan.v2.4.6.jar /usr/share/java/varscan.jar

# Install MultiQC
RUN apt update && apt -y install python3-venv python3-pip \
	&& pip3 install multiqc
	
# Install TreeMix
RUN apt update && apt -y install libboost-all-dev libgsl0-dev \
	&& git clone https://bitbucket.org/nygcresearch/treemix.git \
	&& cd treemix \
 	&& ./configure \
  	&& make \
  	&& make install

# Install FastQC
# No need to install this way as latest version is quite old, and it is already packaged
# by Ubuntu maintainers
#RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip \
	#&& unzip fastqc_v0.11.9.zip && rm fastqc_v0.11.9.zip \
	#&& cd FastQC/ \
	#&& chmod 755 fastqc \
	#&& ln -s /home/rstudio/software/fastqc_v0.11.9/FastQC/fastqc /usr/local/bin/fastqc

# Install Trimmomatic
# No need to install this way as latest version is quite old, and it is already packaged
# by Ubuntu maintainers
#RUN wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip \
	#&& unzip Trimmomatic-0.39.zip \
	#&& rm Trimmomatic-0.39.zip \
	#&& cd Trimmomatic-0.39 \
	#&& ln -s /home/rstudio/software/Trimmomatic-0.39/trimmomatic-0.39.jar /usr/share/trimmomatic-0.39.jar

# Install flash
RUN wget http://ccb.jhu.edu/software/FLASH/FLASH-1.2.11.tar.gz \
	&& tar -xvf FLASH-1.2.11.tar.gz && rm FLASH-1.2.11.tar.gz \
	&& cd FLASH-1.2.11 \
	&& make \
	&& ln -s /home/rstudio/software/FLASH-1.2.11/flash /usr/local/bin/flash
	
# Install bwa
# No need to install this way as bwa latest version is quite old, and it is already packaged
# by Ubuntu maintainers
#RUN git clone https://github.com/lh3/bwa.git \
	#&& cd bwa \
	#&& make \
	#&& ln -s /home/rstudio/software/bwa_repo/bwa/bwa /usr/local/bin/bwa

# Install bwa-mem2
# produces alignment identical to bwa and is ~1.3-3.1x faster depending on the use-case
# Only available for certain CPU models
RUN wget https://github.com/bwa-mem2/bwa-mem2/releases/download/v2.0pre2/bwa-mem2-2.0pre2_x64-linux.tar.bz2 \
	&& tar -jxf bwa-mem2-2.0pre2_x64-linux.tar.bz2 \
	&& mv bwa-mem2-2.0pre2_x64-linux /usr/share/

# Install bedtools
RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools.static.binary \
	&& mv bedtools.static.binary bedtools \
	&& chmod a+x bedtools \
	&& mv /home/rstudio/software/bedtools /usr/local/bin/bedtools

# Install samtools
RUN apt -qq update && apt -y install libncurses5-dev libbz2-dev bzip2 liblzma-dev
RUN wget https://github.com/samtools/samtools/releases/download/1.16/samtools-1.16.tar.bz2 \
	&& tar -xvf samtools-1.16.tar.bz2 && rm samtools-1.16.tar.bz2 \
	&& cd samtools-1.16/ \
	&& ./configure \
	&& make \
	&& make install

# Install BCFtools
RUN wget https://github.com/samtools/bcftools/releases/download/1.16/bcftools-1.16.tar.bz2 \
	&& tar -xvf bcftools-1.16.tar.bz2 && rm bcftools-1.16.tar.bz2 \
	&& cd bcftools-1.16/ \
	&& ./configure \
	&& make \
	&& make install

# Install htslib
RUN wget https://github.com/samtools/htslib/releases/download/1.16/htslib-1.16.tar.bz2 \
	&& tar -xvf htslib-1.16.tar.bz2 && rm htslib-1.16.tar.bz2 \
	&& cd htslib-1.16/ \
	&& ./configure \
	&& make \
	&& make install

# Install freebayes
RUN wget https://github.com/freebayes/freebayes/releases/download/v1.3.6/freebayes-1.3.6-linux-amd64-static.gz \
	&& gunzip freebayes-1.3.6-linux-amd64-static.gz \
	&& chmod +x freebayes-1.3.6-linux-amd64-static \
	&& mv freebayes-1.3.6-linux-amd64-static /usr/local/bin/freebayes

# Install vcftools
RUN wget https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz \
	&& tar -xvf vcftools-0.1.16.tar.gz && rm vcftools-0.1.16.tar.gz \
	&& cd vcftools-0.1.16/ \
	&& ./configure \
	&& make \
	&& make install

# Install Popoolation2
RUN wget https://sourceforge.net/projects/popoolation2/files/latest/download \
	-O popoolation2_1201.zip \
	&& unzip popoolation2_1201.zip && rm popoolation2_1201.zip \
	&& mv popoolation2_1201 /usr/share/

# Install seqtk
# No need to install this way as latest version is quite old, and it is already packaged
# by Ubuntu maintainers
#RUN apt update -qq \
 	#&& apt -y install zlib1g-dev \
	#&& git clone https://github.com/lh3/seqtk.git \
	#&& cd seqtk \
	#&& make
	#&& ln -s /programs/seqtk /usr/local/bin/seqtk

# Install ea-utils
# No need to install this way as latest version is quite old, and it is already packaged
# by Ubuntu maintainers
#RUN apt update -qq \
	#&& apt -y install libgsl0-dev zlib1g-dev build-essential \
	#&& git clone https://github.com/ExpressionAnalysis/ea-utils.git \
	#&& cd ea-utils/clipper \
	#&& make \
	#&& make install \
	#&& rm -rf ../../ea-utils/ #remove files - make admin happy

# Install gatk
# Code left for legacy reasons
# No need to install it, as broadinstitute provides a dedicated container for gatk
# https://hub.docker.com/r/broadinstitute/gatk
#RUN wget https://github.com/broadinstitute/gatk/releases/download/4.3.0.0/gatk-4.3.0.0.zip \
#	&& unzip gatk-4.3.0.0.zip \
#	&& rm gatk-4.3.0.0.zip \
#	&& mv gatk-4.3.0.0 /usr/share/

# Install picard
RUN wget https://github.com/broadinstitute/picard/releases/download/3.0.0/picard.jar \
	&& ln -s /home/rstudio/software/picard.jar /usr/share/java/picard.jar

# Install bam-readcount
RUN git clone https://github.com/genome/bam-readcount \
	&& cd bam-readcount \
	&& mkdir build \
	&& cd build \
	&& cmake .. \
	&& make
RUN mv /home/rstudio/software/bam-readcount/build/bin/bam-readcount /usr/bin/bam-readcount

# Install Bayescan
RUN mkdir /home/rstudio/software/bayescan \
  && cd /home/rstudio/software/bayescan \
  && wget http://cmpg.unibe.ch/software/BayeScan/files/BayeScan2.1.zip \
  && unzip BayeScan2.1.zip \
  && rm -rf BayeScan2.1.zip \
  && cp /home/rstudio/software/bayescan/BayeScan2.1/binaries/BayeScan2.1_linux64bits \
  /usr/local/bin/bayescan

# Install pixy
# make sure to have pip installed previously
RUN wget -qO- "https://github.com/ksamuk/pixy/archive/refs/tags/1.2.7.beta1.tar.gz" | tar -zx
RUN pip install pixy-1.2.7.beta1/

# Install python 2 for legacy scripts
RUN apt update && apt -y install python2

# Install msmc2
RUN apt update && apt -y install libgsl-dev libgsl27 libgslcblas0 libgsl-dbg
RUN wget https://github.com/stschiff/msmc2/releases/download/v2.1.4/msmc2_Linux \
        && chmod +x msmc2_Linux \
        && mv /home/rstudio/software/msmc2_Linux /usr/local/bin/msmc2

# Install R packages from Bioconductor
RUN R -e "BiocManager::install(c('qvalue', 'ggtree'))"

# Install R packages from CRAN
RUN apt update -qq \
  	&& apt -y install libudunits2-dev # needed for scatterpie
RUN install2.r --error \
  	viridis \
  	multcomp \
  	ggThemeAssist \
  	remedy \
  	factoextra \
  	kableExtra \
  	scatterpie \
  	ggmap \
  	ggsn \
  	splitstackshape \
  	gridGraphics \
	gridExtra \
  	officer \
  	flextable \
  	eulerr \
	car \
	sjstats \
	psych \
  	gghalves \
  	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# The following section is copied from hlapp/rpopgen Dockerfile
# It is copied instead of using it as a base for this image because it is not 
# updated regularly

#------------------------------------------------------------------------------
## Some of the R packages depend on libraries not already installed in the
## base image, so they need to be installed here for the R package
## installations to succeed.
#RUN apt-get update \
    #&& apt-get install -y \
    #libgsl0-dev \
    #libmagick++-dev \
    #libudunits2-dev \
    #gdal-bin \
    #libgdal-dev

## Install population genetics packages from CRAN
RUN rm -rf /tmp/*.rds \
&&  install2.r --error \
	poolfstat \
	pcadapt \
	OptM \
	vcfR \
&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds
#------------------------------------------------------------------------------

# Install EAA analysis software

## depencencies
RUN apt update && apt -y --no-install-recommends \
	install gdal-bin proj-bin libgdal-dev libproj-dev 

## R packages from CRAN
RUN install2.r --error \
        raster \
        rgeos \
        rgdal \
        maps \
        sf \
        corrplot \
        FactoMineR \
        factoextra \
        ggpubr \
        lfmm \
        plyr \
        gdm \
        foreach \
        parallel \
        doParallel \    
        fields \
        geosphere \
        plotly \
        manipulateWidget \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds


RUN install2.r --error \
        gradientForest -r http://R-Forge.R-project.org \
        extendedForest -r http://R-Forge.R-project.org \
  	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds

## Install R packages from github
### GAPIT3 needs LDheatmap, but LDheatmap is no longer in CRAN. So install it
RUN R -e "BiocManager::install(c('snpStats','rtracklayer','GenomicRanges','GenomInfoDb','IRanges'))"
RUN installGithub.r \
	SFUStatgen/LDheatmap

RUN installGithub.r \
  	jiabowang/GAPIT3 \
  	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Clean up
RUN apt clean all \
&& rm -rf /var/lib/apt/lists/* && rm -rf /tmp/* && rm -rf /var/tmp/*
