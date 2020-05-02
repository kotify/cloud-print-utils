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
${PIXBUF_BIN} > /opt/lib/loaders.cache
# pixbuf need mime database
# https://www.linuxtopia.org/online_books/linux_desktop_guides/gnome_2.14_admin_guide/mimetypes-database.html
cp -r /usr/share/mime /opt/lib/mime

cd /opt
zip -r9 /out/layer.zip lib/*
