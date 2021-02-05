# Cloud Print Utils

This is a collection of AWS Lambda layers and functions to render pdf documents
and images from HTML.

Currently solutions based on these tools available:

- [WeasyPrint](https://weasyprint.org/)
- [wkhtmltopdf](https://wkhtmltopdf.org/)

To build a layer you need **make** and **docker** installed on your system.
The layers support only amazon linux 2 runtimes, eg. python3.8, nodejs12.x.

By default only dejavu fonts are installed, edit [build script](fonts/layer_builder.sh) to install others.

## WeasyPrint

[WeasyPrint](https://weasyprint.org/) is python based pdf/png print service.

Run `make build/weasyprint-layer-python3.8.zip` to build a layer, for details
see related [readme](weasyprint/README.md).

## wkhtmltopdf

[wkhtmltopdf](https://wkhtmltopdf.org/) is a comand line tool that renders HTML
into PDF and various image formats using the Qt WebKit rendering engine.

Run `make build/wkhtmltox-layer.zip` to build a layer, for details
see related [readme](wkhtmltox/README.md).
