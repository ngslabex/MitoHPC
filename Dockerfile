FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# MitoHPC yolları
ENV HP_HDIR=/MitoHPC
ENV HP_SDIR=/MitoHPC/scripts
ENV HP_BDIR=/MitoHPC/bin
ENV HP_ADIR=bams
ENV HP_ODIR=out
ENV HP_IN=in.txt
ENV PATH="$HP_SDIR:$HP_BDIR:$PATH"

# Tüm RUN komutlarını bash ile çalıştır
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Temel paketler (sudo dahil!)
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      ca-certificates wget curl git nano tar bash coreutils \
      build-essential sudo lsb-release locales tzdata \
      && rm -rf /var/lib/apt/lists/*

# Repo
RUN set -eux \
 && git clone https://github.com/ngslabex/MitoHPC "$HP_HDIR" \
 && if compgen -G "$HP_SDIR/*.sh" > /dev/null; then chmod a+x "$HP_SDIR"/*.sh; fi

WORKDIR /MitoHPC

# Sistem önkoşulları
RUN set -eux \
 && source "$HP_SDIR/init.sh" \
 && "$HP_SDIR/install_sysprerequisites.sh"

# Varsayılan kurulum
RUN set -eux \
 && source "$HP_SDIR/init.sh" \
 && "$HP_SDIR/install_prerequisites.sh"

# rCRS üçlüsü
RUN set -eux \
 && source "$HP_SDIR/init.sh" \
 && HP_MT=rCRS  HP_MTC=rCRSC  HP_MTR=rCRSR  "$HP_SDIR/install_prerequisites.sh"

# RSRS üçlüsü
RUN set -eux \
 && source "$HP_SDIR/init.sh" \
 && HP_MT=RSRS  HP_MTC=RSRSC  HP_MTR=RSRSR  "$HP_SDIR/install_prerequisites.sh"

# Sadece HP_MT=RSRS (gerekliyse)
RUN set -eux \
 && source "$HP_SDIR/init.sh" \
 && HP_MT=RSRS "$HP_SDIR/install_prerequisites.sh"

# Kurulum kontrolü
RUN set -eux \
 && source "$HP_SDIR/init.sh" \
 && "$HP_SDIR/checkInstall.sh"

# Temizlik
RUN rm -rf /MitoHPC/prerequisites/ /MitoHPC/examples*

# Çalışma dizini
WORKDIR /work
