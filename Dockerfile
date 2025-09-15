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

# Tüm RUN komutlarını bash ile çalıştır (dash yerine)
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

###########################################
# Temel paketler
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      ca-certificates wget curl git nano tar bash coreutils build-essential \
      && rm -rf /var/lib/apt/lists/*

###########################################
# Kaynakları klonla ve kur
RUN set -euxo pipefail \
 && git clone https://github.com/ngslabex/MitoHPC "$HP_HDIR" \
 # Betikleri çalıştırılabilir yap (sadece .sh dosyaları)
 && if compgen -G "$HP_SDIR/*.sh" > /dev/null; then chmod a+x "$HP_SDIR"/*.sh; fi \
 # Ortamı içe al (bash ile), değişkenlerin export edilmesini garanti et
 && set -a \
 && source "$HP_SDIR/init.sh" \
 && set +a \
 # Sistem önkoşulları
 && "$HP_SDIR/install_sysprerequisites.sh" \
 # Varsayılan kurulum (referanslar olmadan)
 && "$HP_SDIR/install_prerequisites.sh" \
 # rCRS üçlüsü
 && HP_MT=rCRS  HP_MTC=rCRSC  HP_MTR=rCRSR  "$HP_SDIR/install_prerequisites.sh" \
 # RSRS üçlüsü
 && HP_MT=RSRS  HP_MTC=RSRSC  HP_MTR=RSRSR  "$HP_SDIR/install_prerequisites.sh" \
 # Sadece HP_MT=RSRS ile tekrar (gerekiyorsa)
 && HP_MT=RSRS "$HP_SDIR/install_prerequisites.sh" \
 # Kurulum kontrolü
 && "$HP_SDIR/checkInstall.sh" \
 # Boyutu küçült: örnekler ve önkoşul kaynakları
 && rm -rf /MitoHPC/prerequisites/ /MitoHPC/examples*

# (Opsiyonel) çalışma dizini
WORKDIR /work
