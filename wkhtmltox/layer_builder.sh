#!/bin/bash
set -e
export VERSION="0.12.6-1"

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

curl -LO "https://github.com/wkhtmltopdf/packaging/releases/download/$VERSION/wkhtmltox-$VERSION.centos7.x86_64.rpm"
rpmdev-extract wkhtmltox-*rpm
mkdir /opt/bin
cp /tmp/*/usr/local/bin/wkhtmlto* /opt/bin/

cd /opt
zip -r9 /out/layer.zip lib/* bin/*
