#!/bin/bash
set -e
export VERSION="10.02.1"

dnf install -y gcc tar
cd /tmp/
curl -L -s https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs${VERSION//./}/ghostscript-${VERSION}.tar.gz | tar zxf -
cd ghostscript-*
./configure --prefix=/opt
make && make install
cd /opt
zip -r9 /out/layer.zip bin/gs
