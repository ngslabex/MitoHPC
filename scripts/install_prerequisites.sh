#!/usr/bin/env bash
set -x

if [ -z $HP_SDIR ] ; then echo "Variable HP_SDIR not defined. Make sure you followed the SETUP ENVIRONMENT instructions" ;  exit 0 ; fi
if [ -z $HP_HDIR ] ; then echo "Variable HP_HDIR not defined. Make sure you followed the SETUP ENVIRONMENT instructions" ;  exit 0 ; fi

##############################################################################################################

# Program that downloads and installs software prerequisites and genome reference
#  -f : opt; force reinstall
##############################################################################################################


#. $HP_SDIR/init.sh
cd $HP_HDIR
mkdir -p prerequisites/ $HP_BDIR/ $HP_JDIR/ $HP_RDIR/
cd prerequisites/

which bwa
if [[ $? != 0 || $# == 1 && $1 == "-f" ]] ; then
  wget -N -c --no-check-certificate https://github.com/lh3/bwa/archive/refs/tags/v0.7.19.tar.gz
  if [ ! -s $HP_BDIR/bwa ] ; then
    tar -xvf v0.7.19.tar.gz
    cd bwa-0.7.19
    make CFLAGS="-g -Wall -Wno-unused-function -O2 -fcommon"  # compiling using gcc v10.+ fails unless "-fcommon" is added
    cp bwa $HP_BDIR/
    cd -
  fi
fi

which samtools
if [[ $? != 0 || $# == 1 && $1 == "-f" ]] ; then
  wget -N -c https://github.com/samtools/samtools/releases/download/1.22.1/samtools-1.22.1.tar.bz2
  if [ ! -s $HP_BDIR/samtools ] ; then
    tar -xjvf samtools-1.22.1.tar.bz2
    cd samtools-1.22.1
    ./configure --prefix=$HP_HDIR/ # --without-curses --disable-bz2
    make ;  make install
    cd -
  fi
fi

which bcftools
if [[ $? != 0 || $# == 1 && $1 == "-f" ]] ; then
  wget -N -c https://github.com/samtools/bcftools/releases/download/1.22/bcftools-1.22.tar.bz2
  if [ ! -s $HP_BDIR/bcftools ] ; then
    tar -xjvf  bcftools-1.22.tar.bz2
    cd bcftools-1.22
    ./configure --prefix=$HP_HDIR/ # --disable-bz2
    make ; make install
    cd -
  fi
fi

which htsfile
if [[ $? != 0 || $# == 1 && $1 == "-f" ]] ; then
  wget -N -c https://github.com/samtools/htslib/releases/download/1.22.1/htslib-1.22.1.tar.bz2
  if [ ! -s $HP_BDIR/tabix ] ; then
    tar -xjvf htslib-1.22.1.tar.bz2
    cd htslib-1.22.1
    ./configure --prefix=$HP_HDIR/ # --disable-bz2
    make ; make install
    cd -
  fi
fi

which samblaster
if [[ $? != 0 || $# == 1 && $1 == "-f" ]] ; then
  wget -N -c https://github.com/GregoryFaust/samblaster/releases/download/v.0.1.26/samblaster-v.0.1.26.tar.gz
  if [ ! -s $HP_BDIR/samblaster ] ; then
    tar -xzvf samblaster-v.0.1.26.tar.gz
    cd samblaster-v.0.1.26
    make ; cp samblaster $HP_BDIR/
    cd -
  fi
fi

which bedtools
if [[ $? != 0 || $# == 1 && $1 == "-f" ]] ; then
  wget -N -c https://github.com/arq5x/bedtools2/releases/download/v2.31.1/bedtools-2.31.1.tar.gz
  if [ ! -s $HP_BDIR/bedtools ] ; then
    tar -xzvf bedtools-2.31.1.tar.gz
    cd bedtools2/
    make install prefix=$HP_HDIR/
    cd -
  fi

  #wget -N -c https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools.static.binary
  #cp bedtools.static.binary $HP_BDIR/bedtools
  #chmod a+x $HP_BDIR/bedtools
fi

which fastp
if [[ $? != 0 || $# == 1 && $1 == "-f" ]] ; then
  wget -N -c http://opengene.org/fastp/fastp
  cp fastp $HP_BDIR/
  chmod a+x $HP_BDIR/fastp
fi

which freebayes
if [[ $? != 0 || $# == 1 && $1 == "-f" ]] ; then
  wget -N -c https://github.com/freebayes/freebayes/releases/download/v1.3.10/freebayes-1.3.10-linux-amd64-static.gz
  gunzip freebayes-1.3.10-linux-amd64-static.gz  -c >  $HP_BDIR/freebayes
  chmod a+x $HP_BDIR//freebayes
fi

which gridss
if [[ $? != 0 || $# == 1 && $1 == "-f" ]] ; then
  wget https://github.com/PapenfussLab/gridss/releases/download/v2.13.2/gridss-2.13.2.tar.gz
  tar -xzvf gridss-2.13.2.tar.gz
  cp gridss $HP_BDIR/
  cp gridss-2.13.2-gridss-jar-with-dependencies.jar $HP_JDIR/gridss.jar
fi

which minimap2
if [[ $? != 0 || $# == 1 && $1 == "-f" ]] ; then
  wget -N -c https://github.com/lh3/minimap2/releases/download/v2.30/minimap2-2.30.tar.bz2
  tar -xjvf minimap2-2.30.tar.bz2
  cd minimap2-2.30/
  make;  cp minimap2 $HP_BDIR
  cd -
fi

#if [ ! -s $HP_JDIR/gatk.jar ] ; then # 2023/04/26
if [[ ! -s $HP_JDIR/gatk.jar || $# == 1 && $1 == "-f" ]] ; then
  wget -N -c https://github.com/broadinstitute/gatk/releases/download/4.6.2.0/gatk-4.6.2.0.zip
  unzip -o gatk-4.6.2.0.zip
  cp gatk-4.6.2.0/gatk-package-4.6.2.0-local.jar $HP_JDIR/gatk.jar
  cp gatk-4.6.2.0/gatk $HP_BDIR/
fi

#if [ ! -s $HP_JDIR/haplogrep.jar ] ; then # 2023/04/26
if [[ ! -s $HP_JDIR/haplogrep.jar || $# == 1 && $1 == "-f" ]] ; then
  wget -N -c https://github.com/seppinho/haplogrep-cmd/releases/download/v2.4.0/haplogrep.zip
  unzip -o haplogrep.zip
  cp haplogrep.jar $HP_JDIR/
fi

#if [ ! -s $HP_JDIR/haplocheck.jar ] ; then # 2023/04/26
if [[ ! -s $HP_JDIR/haplocheck.jar || $# == 1 && $1 == "-f" ]] ; then
  wget -N -c https://github.com/genepi/haplocheck/releases/download/v1.3.3/haplocheck.zip
  unzip -o haplocheck.zip
  cp haplocheck.jar $HP_JDIR/
fi

#if [ ! -s $HP_JDIR/mutserve.jar ] ; then  # 2023/04/26
if [[ ! -s $HP_JDIR/mutserve.jar || $# == 1 && $1 == "-f" ]] ; then
  wget -N -c https://github.com/seppinho/mutserve/releases/download/v2.0.3/mutserve.zip
  unzip -o mutserve.zip
  cp mutserve.jar $HP_JDIR
fi

#if [ ! -s $HP_RDIR/$HP_RNAME.fa ] ; then # 2023/04/26
if [[ ! -s $HP_RDIR/$HP_RNAME.fa.fai || $# == 1 && $1 == "-f" ]] ; then
  wget -qO- $HP_RURL | zcat -f > $HP_RDIR/$HP_RNAME.fa
  samtools faidx $HP_RDIR/$HP_RNAME.fa
fi

#if [ ! -s $HP_RDIR/$HP_MT.fa ] ; then  # 2023/04/26
if [[ ! -s $HP_RDIR/$HP_MT.dict || $# == 1 && $1 == "-f"  ]] ; then
  samtools faidx $HP_RDIR/$HP_RNAME.fa $HP_RMT > $HP_RDIR/$HP_MT.fa
  samtools faidx $HP_RDIR/$HP_MT.fa
  java $HP_JOPT -jar $HP_JDIR/gatk.jar CreateSequenceDictionary --REFERENCE $HP_RDIR/$HP_MT.fa --OUTPUT $HP_RDIR/$HP_MT.dict
fi

#if [ ! -s $HP_RDIR/$HP_NUMT.fa ] ; then # 2023/04/26
if [[ ! -s $HP_RDIR/$HP_NUMT.bwt || $# == 1 && $1 == "-f"  ]] ; then
  samtools faidx $HP_RDIR/$HP_RNAME.fa $HP_RNUMT > $HP_RDIR/$HP_NUMT.fa
  bwa index $HP_RDIR/$HP_NUMT.fa -p $HP_RDIR/$HP_NUMT
fi

#if [ ! -s $HP_RDIR/$HP_MTC.fa ] ; then  # 2023/04/26
if [[ ! -s $HP_RDIR/$HP_MTC.dict || $# == 1 && $1 == "-f" ]] ; then
  circFasta.sh $HP_MT $HP_RDIR/$HP_MT $HP_E $HP_RDIR/$HP_MTC
fi

#if [ ! -s $HP_RDIR/$HP_MTR.fa ] ; then # 2023/04/26
if [[ ! -s $HP_RDIR/$HP_MTR.dict || $# == 1 && $1 == "-f" ]] ; then
  rotateFasta.sh $HP_MT $HP_RDIR/$HP_MT $HP_E $HP_RDIR/$HP_MTR
fi
