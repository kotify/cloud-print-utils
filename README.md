# Cloud Print Utils

This is a collection of AWS Lambda layers and functions to render pdf documents
and images from HTML.

Download layers from release section or build them yourself (requires **make** and **docker**).
The layers support only Amazon Linux 2023 runtimes, eg. python3.12.

By default only dejavu fonts are installed, edit [build script](fonts/layer_builder.sh) to install others.

## WeasyPrint

[WeasyPrint](https://weasyprint.org/) is python based pdf/png print service.

Run `make build/weasyprint-layer-python3.12.zip` to build a layer, for details
and docker lambda example see related [readme](weasyprint/README.md).
