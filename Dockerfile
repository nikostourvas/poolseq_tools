####### Dockerfile #######
FROM rocker/tidyverse:4.2.0
MAINTAINER Nikolaos Tourvas <nikostourvas@gmail.com>

# Create directory for population genetics software on linux
RUN mkdir /home/rstudio/software

# Prevent error messages from debconf about non-interactive frontend
ARG TERM=linux
ARG DEBIAN_FRONTEND=noninteractive

# Install vim
RUN apt update && apt -y install vim
	
# Install TreeMix
RUN apt update && apt -y install libboost-all-dev libgsl0-dev
RUN cd /home/rstudio/software/ \
	&& git clone https://bitbucket.org/nygcresearch/treemix.git \
	&& cd treemix \
 	&& ./configure \
  	&& make \
  	&& make install

# Install R packages from Bioconductor
RUN R -e "BiocManager::install(c('qvalue', 'ggtree'))"

# Install R packages from CRAN
RUN apt-get update -qq \
  	&& apt-get -y install libudunits2-dev # needed for scatterpie
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


