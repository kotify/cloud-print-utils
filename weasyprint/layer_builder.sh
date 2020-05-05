#!/bin/bash
# Don't forget to set these env variables in aws lambda
# GDK_PIXBUF_MODULE_FILE="/opt/lib/loaders.cache"
# XDG_DATA_DIRS="/opt/lib"
set -e
yum install -y yum-utils rpmdevtools
cd /tmp
yumdownloader --resolve \
    cairo.x86_64 \
    gdk-pixbuf2.x86_64 \
    libffi.x86_64 \
    pango.x86_64 \
    expat.x86_64 \
    libmount.x86_64 \
    libuuid.x86_64 \
    libblkid.x86_64 \
    glib2.x86_64 \

rpmdev-extract *rpm

mkdir /opt/lib
cp -P -r /tmp/*/usr/lib64/* /opt/lib
# pixbuf need list loaders cache
# https://developer.gnome.org/gdk-pixbuf/stable/gdk-pixbuf-query-loaders.html
PIXBUF_BIN=$(find /tmp -name gdk-pixbuf-query-loaders-64)
export GDK_PIXBUF_MODULEDIR=$(find /opt/lib/gdk-pixbuf-2.0/ -name loaders)
$PIXBUF_BIN > /opt/lib/loaders.cache
# pixbuf need mime database
# https://www.linuxtopia.org/online_books/linux_desktop_guides/gnome_2.14_admin_guide/mimetypes-database.html
cp -r /usr/share/mime /opt/lib/mime

export RUNTIME=$(echo $AWS_EXECUTION_ENV | cut -d _ -f 3)
mkdir -p /opt/python/lib/$RUNTIME/site-packages
python -m pip install weasyprint -t /opt/python/lib/$RUNTIME/site-packages

# fix dlopen(3) calls
cd /opt/python/lib/$RUNTIME/site-packages
sed -i "s/'libgdk_pixbuf-2.0.so'/'libgdk_pixbuf-2.0.so.0'/" cairocffi/pixbuf.py
sed -i "s/'libgobject-2.0.so'/'libgobject-2.0.so.0'/" cairocffi/pixbuf.py
sed -i "s/'libglib-2.0.so'/'libglib-2.0.so.0'/" cairocffi/pixbuf.py
sed -i "s/'libcairo.so'/'libcairo.so.2'/" cairocffi/__init__.py
sed -i "s/'libfontconfig.so'/'libfontconfig.so.1'/" weasyprint/fonts.py
sed -i "s/'libpangoft2-1.0.so'/'libpangoft2-1.0.so.0'/" weasyprint/fonts.py
sed -i "s/'libgobject-2.0.so'/'libgobject-2.0.so.0'/" weasyprint/fonts.py
sed -i "s/'libpango-1.0.so'/'libpango-1.0.so.0'/" weasyprint/fonts.py
sed -i "s/'libpangocairo-1.0.so'/'libpangocairo-1.0.so.0'/" weasyprint/fonts.py
sed -i "s/'libgobject-2.0.so'/'libgobject-2.0.so.0'/" weasyprint/text.py
sed -i "s/'libpango-1.0.so'/'libpango-1.0.so.0'/" weasyprint/text.py
sed -i "s/'libpangocairo-1.0.so'/'libpangocairo-1.0.so.0'/" weasyprint/text.py

cd /opt
zip -r9 /out/layer.zip lib/* python/*
