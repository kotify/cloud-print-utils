#!/bin/bash
set -e
# wkhtmltox version, on change verify rpm download url
# it can be different from "$VERSION-1"
export VERSION=0.12.5

cd /tmp/
yum install -y yum-utils rpmdevtools
yumdownloader --resolve \
    libjpeg-turbo.x86_64 \
    libpng.x86_64 \
    libXrender.x86_64 \
    libX11.x86_64 \
    libXext.x86_64 \
    freetype.x86_64 \
    fontconfig.x86_64 \
    expat.x86_64 \
    libuuid.x86_64 \

rpmdev-extract -- *rpm
mkdir /opt/lib
cp -P -r /tmp/*/usr/lib64/* /opt/lib/

export DOWNLOAD_URL="https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/$VERSION"
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 8C64CF2A
curl -LO "$DOWNLOAD_URL/SHA256SUMS"
curl -LO "$DOWNLOAD_URL/SHA256SUMS.asc"
gpg --verify SHA256SUMS.asc SHA256SUMS
curl -LO "$DOWNLOAD_URL/wkhtmltox-$VERSION-1.centos7.x86_64.rpm"
grep centos7.x86_64 SHA256SUMS | sha256sum --check
rpmdev-extract wkhtmltox-*rpm
mkdir /opt/bin
cp /tmp/*/usr/local/bin/wkhtmlto* /opt/bin/

cd /opt
zip -r9 /out/layer.zip lib/* bin/*
