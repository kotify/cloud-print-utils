#!/usr/bin/env bash
mkdir build
cd build
mkdir -p python/lib/python3.8/site-packages
python -m pip install "weasyprint>=50" -t python/lib/python3.8/site-packages

# fix dlopen(3) calls
cd python/lib/python3.8/site-packages
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
cd -

zip -r9 /out/weasyprint.zip python
