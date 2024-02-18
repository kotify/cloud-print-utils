#!/bin/bash
# don't fortget to set FONTCONFIG_PATH="/opt/fonts" in your lambda
set -e

dnf install -y rpmdevtools

cd /tmp
# download fonts
dnf download dejavu-sans-fonts
dnf download dejavu-serif-fonts
dnf download dejavu-sans-mono-fonts

rpmdev-extract -- *rpm

mkdir /opt/fonts
# dnf download urw-base35-nimbus-roman-fonts
# find /tmp/*/usr/share/fonts -name '*.afm' -delete -o -name '*.t1' -delete
cp -P -r /tmp/*/usr/share/fonts/* /opt/fonts

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
