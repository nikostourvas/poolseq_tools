####### Dockerfile #######
FROM rocker/tidyverse:4.2.0
MAINTAINER Nikolaos Tourvas <nikostourvas@gmail.com>

# Create directory for population genetics software on linux and use it as working dir
RUN mkdir /home/rstudio/software
WORKDIR /home/rstudio/software

# Prevent error messages from debconf about non-interactive frontend
ARG TERM=linux
ARG DEBIAN_FRONTEND=noninteractive

# Install vim
RUN apt update && apt -y install vim
	
# Install TreeMix
RUN apt update && apt -y install libboost-all-dev libgsl0-dev \
	&& git clone https://bitbucket.org/nygcresearch/treemix.git \
	&& cd treemix \
 	&& ./configure \
  	&& make \
  	&& make install

# Install FastQC
RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip \
	&& unzip fastqc_v0.11.9.zip \
	&& cd FastQC/ \
	&& chmod 755 fastqc \
	&& ln -s /home/rstudio/software/fastqc_v0.11.9/FastQC/fastqc /usr/local/bin/fastqc

# Install Trimmomatic
RUN wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip \
	&& unzip Trimmomatic-0.39.zip

# Install flash
RUN wget http://ccb.jhu.edu/software/FLASH/FLASH-1.2.11.tar.gz \
	&& tar -xvf FLASH-1.2.11.tar.gz \
	&& cd FLASH-1.2.11 \
	&& make \
	&& ln -s /home/rstudio/software/FLASH-1.2.11/flash /usr/local/bin/flash
	
# Install bwa
RUN git clone https://github.com/lh3/bwa.git \
	&& cd bwa \
	&& make \
	&& ln -s /home/rstudio/software/bwa_repo/bwa/bwa /usr/local/bin/bwa

# Install bedtools
RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools.static.binary \
	&& mv bedtools.static.binary bedtools \
	&& chmod a+x bedtools

# Install samtools
RUN apt -qq update && apt -y install libncurses5-dev libbz2-dev liblzma-dev \
	&& wget https://github.com/samtools/samtools/releases/download/1.16/samtools-1.16.tar.bz2 \
	&& tar -xvf samtools-1.16.tar.bz2 \
	&& cd samtools-1.16/ \
	&& ./configure \
	&& make \
	&& make install

# Install BCFtools
RUN wget https://github.com/samtools/bcftools/releases/download/1.16/bcftools-1.16.tar.bz2 \
	&& tar -xvf bcftools-1.16.tar.bz2 \
	&& cd bcftools-1.16/ \
	&& ./configure \
	&& make \
	&& make install

# Install freebayes
RUN wget https://github.com/freebayes/freebayes/releases/download/v1.3.6/freebayes-1.3.6-linux-amd64-static.gz \
	&& gunzip freebayes-1.3.6-linux-amd64-static.gz \
	&& chmod +x freebayes-1.3.6-linux-amd64-static \
	&& mv freebayes-1.3.6-linux-amd64-static freebayes \
	&& ln -s /home/rstudio/software/freebayes /usr/local/bin/freebayes

# Install vcftools
RUN wget https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz \
	&& tar -xvf vcftools-0.1.16.tar.gz \
	&& cd vcftools-0.1.16/ \
	&& ./configure \
	&& make \
	&& make install

# Install varscan
RUN wget https://sourceforge.net/projects/varscan/files/latest/download \
	&& mv download VarScan.jar

# Install Popoolation2
RUN wget https://sourceforge.net/projects/popoolation2/files/latest/download -O popoolation2_1201.zip \
	&& unzip popoolation2_1201.zip

# Install seqtk
RUN apt update -qq \
 	&& apt -y install zlib1g-dev \
	&& git clone https://github.com/lh3/seqtk.git \
	&& cd seqtk \
	&& make
	#&& ln -s /programs/seqtk /usr/local/bin/seqtk

# Install ea-utils
#RUN apt update -qq \
	#&& apt -y install libgsl0-dev zlib1g-dev build-essential \
	#&& git clone https://github.com/ExpressionAnalysis/ea-utils.git \
	#&& cd ea-utils/clipper \
	#&& make \
	#&& make install \
	#&& rm -rf ../../ea-utils/ #remove files - make admin happy

# Install gatk
RUN wget https://github.com/broadinstitute/gatk/releases/download/4.2.6.1/gatk-4.2.6.1.zip \
	&& unzip gatk-4.2.6.1.zip \
	&& rm gatk-4.2.6.1.zip #remove files - make admin happy

# Install picard
RUN wget https://github.com/broadinstitute/picard/releases/download/2.27.1/picard.jar

# Install varscan
RUN wget https://sourceforge.net/projects/varscan/files/latest/download \
	&& mv download VarScan.jar

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
  	ggpubr \ 
  	gridGraphics \
  	officer \
  	flextable \	
  	eulerr \
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


