####### Dockerfile #######
FROM rocker/tidyverse:4.5.2
LABEL maintainer="nikostourvas@gmail.com"

# 1. SYSTEM CONFIGURATION
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=linux \
    PATH=/usr/local/bin:$PATH

# 2. UNIFIED APT INSTALLATION
RUN apt-get update && apt-get install -y --no-install-recommends \
    # --- Core Utilities ---
    vim nano less tree time parallel \
    wget curl git unzip bzip2 gnupg ca-certificates \
    build-essential cmake autoconf automake \
    rename \
    # --- Java ---
    default-jre openjdk-17-jre \
    # --- Python dependencies ---
    python3-dev python3-pip python3-venv \
    # --- Bioinformatics Libraries (Dev headers) ---
    zlib1g-dev libbz2-dev liblzma-dev libtinfo6 \
    libncurses5-dev libcurl4-openssl-dev libxml2-dev libssl-dev \
    libgsl-dev libgsl27 libgslcblas0 \
    libglpk-dev libudunits2-dev \
    libmagick++-dev gdal-bin libgdal-dev libproj-dev \
    # --- Bio Tools available in Ubuntu ---
    bwa trimmomatic fastqc seqtk bamtools ea-utils \
    plink1.9 plink2 phylip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. MANUALLY COMPILED BIOINFORMATICS TOOLS
WORKDIR /usr/local/src

# --- Samtools / Bcftools / Htslib ---
ARG SAM_VER=1.23
RUN wget https://github.com/samtools/samtools/releases/download/${SAM_VER}/samtools-${SAM_VER}.tar.bz2 \
    && tar -xjf samtools-${SAM_VER}.tar.bz2 \
    && cd samtools-${SAM_VER} && ./configure && make && make install \
    && cd .. \
    && wget https://github.com/samtools/bcftools/releases/download/${SAM_VER}/bcftools-${SAM_VER}.tar.bz2 \
    && tar -xjf bcftools-${SAM_VER}.tar.bz2 \
    && cd bcftools-${SAM_VER} && ./configure && make && make install \
    && cd .. \
    && wget https://github.com/samtools/htslib/releases/download/${SAM_VER}/htslib-${SAM_VER}.tar.bz2 \
    && tar -xjf htslib-${SAM_VER}.tar.bz2 \
    && cd htslib-${SAM_VER} && ./configure && make && make install \
    && rm -rf *tools-*.tar.bz2 htslib-*.tar.bz2

# --- Refresh Shared Library Cache ---
# Crucial: Ensures the system finds the libhts.so we just compiled
RUN ldconfig

# 4. PYTHON TOOLS via UV
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Install Python tools
# We set CFLAGS/LDFLAGS so pip finds the HTSlib headers we just compiled in /usr/local
ENV CFLAGS="-I/usr/local/include"
ENV LDFLAGS="-L/usr/local/lib"

RUN uv pip install --system --break-system-packages \
    numpy pandas scipy matplotlib seaborn \
    multiqc \
    dendropy biopython bcbio-gff intermine \
    pyabcranger

# 5. REMAINING BINARIES
WORKDIR /usr/local/src

# TreeMix
RUN apt update && apt -y install libboost-all-dev libgsl0-dev \
	&& git clone https://bitbucket.org/nygcresearch/treemix.git \
	&& cd treemix \
 	&& ./configure \
  	&& make \
  	&& make install

# Popoolation2
RUN wget https://sourceforge.net/projects/popoolation2/files/latest/download \
	-O popoolation2_1201.zip \
	&& unzip popoolation2_1201.zip && rm popoolation2_1201.zip \
	&& mv popoolation2_1201 /usr/share/

# --- BWA-MEM2 ---
RUN wget https://github.com/bwa-mem2/bwa-mem2/releases/download/v2.2.1/bwa-mem2-2.2.1_x64-linux.tar.bz2 \
    && tar -xjf bwa-mem2-2.2.1_x64-linux.tar.bz2 \
    && mv bwa-mem2-2.2.1_x64-linux/bwa-mem2* /usr/local/bin/ \
    && rm -rf bwa-mem2*

# --- Bedtools ---
RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.31.0/bedtools.static \
    && chmod +x bedtools.static \
    && mv bedtools.static /usr/local/bin/bedtools

# --- Freebayes ---
RUN wget https://github.com/freebayes/freebayes/releases/download/v1.3.6/freebayes-1.3.6-linux-amd64-static.gz \
    && gunzip freebayes-1.3.6-linux-amd64-static.gz \
    && chmod +x freebayes-1.3.6-linux-amd64-static \
    && mv freebayes-1.3.6-linux-amd64-static /usr/local/bin/freebayes

# --- VCFtools ---
# Manually compiling this replaces the need for libvcflib-tools
RUN wget https://github.com/vcftools/vcftools/releases/download/v0.1.17/vcftools-0.1.17.tar.gz \
    && tar -xzf vcftools-0.1.17.tar.gz \
    && cd vcftools-0.1.17 && ./configure && make && make install \
    && cd .. && rm -rf vcftools*

# --- GATK & Picard ---
RUN mkdir -p /opt/gatk \
    && wget https://github.com/broadinstitute/gatk/releases/download/4.6.2.0/gatk-4.6.2.0.zip \
    && unzip -q gatk-4.6.2.0.zip \
    && mv gatk-4.6.2.0/* /opt/gatk/ \
    && ln -s /opt/gatk/gatk /usr/local/bin/gatk \
    && rm gatk-4.6.2.0.zip \
    && wget https://github.com/broadinstitute/picard/releases/download/3.4.0/picard.jar \
    && mv picard.jar /usr/share/java/picard.jar

# --- Baypass ---
RUN git clone https://forgemia.inra.fr/mathieu.gautier/baypass_public.git \
    && cd baypass_public/sources \
    && make clean all FC=gfortran \
    && mv g_baypass /usr/local/bin/g_baypass \
    && cd ../.. && rm -rf baypass_public

# --- PopLDdecay ---
RUN wget https://github.com/hewm2008/PopLDdecay/archive/v3.43.tar.gz \
    && tar -zxf v3.43.tar.gz \
    && cd PopLDdecay-3.43/src \
    && sh make.sh \
    && cp -r ../bin/* /usr/local/bin/ \
    && cd ../.. && rm -rf PopLDdecay* v3.43.tar.gz

# --- Mosdepth ---
RUN wget https://github.com/brentp/mosdepth/releases/download/v0.3.12/mosdepth \
    && chmod a+x mosdepth \
    && mv mosdepth /usr/local/bin/mosdepth

# Install minimap2
RUN wget https://github.com/lh3/minimap2/releases/download/v2.26/minimap2-2.26_x64-linux.tar.bz2 \
	&& tar -jxvf minimap2-2.26_x64-linux.tar.bz2 \
	&& mv minimap2-2.26_x64-linux/minimap2 /usr/local/bin/minimap2

# Install bowtie2
# RUN wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.5.2/bowtie2-2.5.2-source.zip/download \
# 	&& unzip download \
# 	&& cd bowtie2-2.5.2 \
# 	&& make
# RUN cd bowtie2-2.5.2 \
# 	&& cp bowtie2* /usr/local/bin/

# Install DIYABC RF (pending install of diyabcGUI R package)
RUN git clone --recurse-submodules https://github.com/diyabc/diyabc.git \
	&& cd diyabc \
	&& mkdir build \
	&& cd build \
	&& cmake ../ \
	&& cmake --build . --config Release

# Install grenedalf
RUN git clone --recursive https://github.com/lczech/grenedalf.git \
	&& cd grenedalf \
	&& make -j 4 \
	&& mv bin/grenedalf /usr/local/bin/grenedalf

# Install fastsimcoal2
RUN wget http://cmpg.unibe.ch/software/fastsimcoal28/downloads/fsc28_linux64.zip \
	&& unzip fsc28_linux64.zip \
	&& mv fsc28_linux64/fsc28 /usr/local/bin/ \
	&& rm fsc28_linux64/fastsimcoal28.pdf

# Install blast+
RUN wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.17.0+-x64-linux.tar.gz \
	&& tar -xvf ncbi-blast-2.17.0+-x64-linux.tar.gz
RUN rm ncbi-blast-2.17.0+-x64-linux.tar.gz \
	&& mv ncbi-blast-2.17.0+/bin/* /usr/local/bin/ \
	&& rm -rf ncbi-blast-2.17.0+


# 6. R PACKAGES
# --- CRAN PACKAGES ---
RUN install2.r --error --skipinstalled -n 4 \
    --repos https://cran.rstudio.com \
    # Utilities & Plotting
    viridis multcomp remedy factoextra scatterpie ggmap splitstackshape \
    gridGraphics gridExtra officer flextable eulerr car sjstats psych \
    data.table ggrepel optparse

RUN install2.r --error --skipinstalled -n 4 \
    --repos https://cran.rstudio.com \
    # PopGen & Stats
    adegenet poppr hierfstat pegas ape phytools scales vegan \
    gtools reshape reshape2 gplots gsalib gdistance mclust \
    mvtnorm geigen poolfstat pcadapt OptM vcfR conStruct \
    poolr \
	usdm ClustOfVar lme4 lmerTest emmeans MuMIn 
    # poolr

RUN install2.r --error --skipinstalled -n 4 \
    --repos https://cran.rstudio.com \
    # Spatial & Env
    raster maps sf corrplot FactoMineR ggpubr \
    plyr gdm foreach doParallel fields geosphere \
    terra rnaturalearth geodata plotly manipulateWidget

# --- R-FORGE PACKAGES ---
RUN install2.r --error --skipinstalled -r http://R-Forge.R-project.org \
    gradientForest extendedForest

# --- BIOCONDUCTOR ---
# Note: 'LEA' replaces the old 'lfmm' package
RUN R -e "BiocManager::install(c(\
    'NOISeq','Repitools','Rsamtools','GenomicFeatures','rtracklayer', \
    'qvalue', 'ggtree', 'LEA', \
    'snpStats', 'GenomicRanges', 'GenomInfoDb', 'IRanges', \
    'SNPRelate', 'gdsfmt', 'geneplotter', 'topGO', 'Rgraphviz' \
    ))"

# --- GITHUB PACKAGES ---
# poolHelper and poolABC are usually installed from GitHub
RUN R -e "remotes::install_github(c(\
    'SFUStatgen/LDheatmap', \
    'jiabowang/GAPIT3', \
    'TBooker/PicMin', \
    'landscape-genomics/rdadapt', \
    'joao-mcarvalho/poolABC' \
    ))"
    # poolHelper is currently not on GitHub

# --- ARCHIVED PACKAGES ---
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/RCircos/RCircos_1.1.3.tar.gz', repos=NULL)" \
    && R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/BITE/BITE_1.2.0008.tar.gz', repos=NULL)"

	# 7. FINAL CLEANUP
WORKDIR /home/rstudio
RUN ldconfig