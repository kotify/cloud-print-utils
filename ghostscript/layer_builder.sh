#!/bin/bash
set -e
# Pin the Ghostscript version when GHOSTSCRIPT_VERSION is set; otherwise use the default.
export VERSION="${GHOSTSCRIPT_VERSION:-10.07.1}"

dnf install -y gcc tar
cd /tmp/
curl -L -s https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs${VERSION//./}/ghostscript-${VERSION}.tar.gz | tar zxf -
cd ghostscript-*
./configure --prefix=/opt
make && make install
cd /opt
zip -r9 /out/layer.zip bin/gs
