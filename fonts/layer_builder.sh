#!/bin/bash
# don't fortget to set FONTCONFIG_PATH="/opt/fonts" in your lambda
set -e
yum install -y yum-utils rpmdevtools
cd /tmp
# download fonts
yumdownloader \
    dejavu-sans-fonts \
    dejavu-fonts-common \
    xorg-x11-fonts-Type1 "$@"

rpmdev-extract -- *rpm

mkdir /opt/fonts
cp -P -r /tmp/*/usr/share/fonts/* /opt/fonts
cp -P -r /tmp/*/usr/share/X11/fonts/* /opt/fonts
cat > /opt/fonts/fonts.conf <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>/opt/fonts/</dir>
  <cachedir>/tmp/fonts-cache/</cachedir>
  <config></config>
</fontconfig>
EOF

cd /opt
zip -r9 /out/layer.zip fonts/*
