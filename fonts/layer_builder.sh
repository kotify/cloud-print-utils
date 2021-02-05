#!/bin/bash
# don't fortget to set FONTCONFIG_PATH="/opt/fonts" in your lambda
set -e
yum install -y yum-utils rpmdevtools
cd /tmp
# download fonts
yumdownloader \
    dejavu-sans-fonts \
    dejavu-fonts-common

rpmdev-extract -- *rpm

mkdir /opt/fonts
cp -P -r /tmp/*/usr/share/fonts/* /opt/fonts

if [ "$INSTALL_MS_FONTS" = "yes" ]; then
    PYTHON=python2 amazon-linux-extras install epel -y
    yum install -y fontconfig xorg-x11-font-utils cabextract
    curl -L -O https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
    rpm -i msttcore-fonts-installer-2.6-1.noarch.rpm
    cp -P -r /usr/share/fonts/msttcore /opt/fonts/
fi

cat > /opt/fonts/fonts.conf <<EOF
<?xml version="1.0" ?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>/opt/fonts/</dir>
  <cachedir>/tmp/fonts-cache/</cachedir>

  <match target="pattern">
    <test qual="any" name="family">
      <string>mono</string>
    </test>
    <edit name="family" mode="assign" binding="same">
      <string>monospace</string>
    </edit>
  </match>

  <match target="pattern">
    <test qual="any" name="family">
      <string>sans serif</string>
    </test>
    <edit name="family" mode="assign" binding="same">
      <string>sans-serif</string>
    </edit>
  </match>

  <match target="pattern">
    <test qual="any" name="family">
      <string>sans</string>
    </test>
    <edit name="family" mode="assign" binding="same">
      <string>sans-serif</string>
    </edit>
  </match>

  <config></config>
</fontconfig>
EOF

cd /opt
zip -r9 /out/layer.zip fonts/*
