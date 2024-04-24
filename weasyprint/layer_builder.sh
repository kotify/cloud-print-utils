#!/bin/bash
# Don't forget to set these env variables in aws lambda
# GDK_PIXBUF_MODULE_FILE="/opt/lib/loaders.cache"
# XDG_DATA_DIRS="/opt/lib"
set -e
dnf install -y rpmdevtools
cd /tmp
dnf download cairo
dnf download gdk-pixbuf2
dnf download libffi
dnf download pango
dnf download expat
dnf download libmount
dnf download libuuid
dnf download libblkid
dnf download glib2
dnf download libthai
dnf download fribidi
dnf download harfbuzz
dnf download libdatrie
dnf download freetype
dnf download graphite2
dnf download libbrotli
dnf download libpng
dnf download fontconfig

# pixbuf need mime database
# https://www.linuxtopia.org/online_books/linux_desktop_guides/gnome_2.14_admin_guide/mimetypes-database.html
dnf download shared-mime-info

rpmdev-extract -- *rpm

mkdir /opt/lib
cp -P -r /tmp/*/usr/lib64/* /opt/lib
for f in $(find /tmp  -type f  -name 'lib*.so*'); do 
  cp "$f" /opt/lib/$(python -c "import re; print(re.match(r'^(.*.so.\d+).*$', '$(basename $f)').groups()[0])"); 
done
# pixbuf need list loaders cache
# https://developer.gnome.org/gdk-pixbuf/stable/gdk-pixbuf-query-loaders.html
PIXBUF_BIN=$(find /tmp -name gdk-pixbuf-query-loaders-64)
GDK_PIXBUF_MODULEDIR=$(find /opt/lib/gdk-pixbuf-2.0/ -name loaders)
export GDK_PIXBUF_MODULEDIR
$PIXBUF_BIN > /opt/lib/loaders.cache

RUNTIME=$(grep AWS_EXECUTION_ENV "$LAMBDA_RUNTIME_DIR/bootstrap" | cut -d _ -f 5)
export RUNTIME
mkdir -p "/opt/python/lib/$RUNTIME/site-packages"
python -m pip install "weasyprint" -t "/opt/python/lib/$RUNTIME/site-packages"

cd /opt
zip -r9 /out/layer.zip lib/* python/*
