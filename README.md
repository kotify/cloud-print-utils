# Cloud Print Utils

This is a collection of AWS Lambda layers and functions to render pdf documents and images from HTML.

Download layers from release section or build them yourself (requires: make, docker, zip, unzip, jq).
The layers support only Amazon Linux 2023 runtimes, eg. python3.12 and python3.13.

## Fonts

Run `make build/fonts-layer.zip` to build the layer. 
By default only dejavu fonts are installed, edit [build script](fonts/layer_builder.sh) to install others.

## Ghostscript

[Ghostscript](https://www.ghostscript.com/) is a PDF rendering engine.

Run `make build/ghostscript-layer.zip` to build the layer.

## WeasyPrint

[WeasyPrint](https://weasyprint.org/) is python based pdf print service.

### Native layer

Build the layer with:

    $ make build/weasyprint-layer-python3.12-x86_64.zip

To test your build:

    $ make test.start.container
    # a timestamp followed by "exec '/var/runtime/bootstrap'" should appear
    # "docker ps" should show a running container

    # in a new shell, run
    $ make test.print.report
    # a report.pdf file will generate to the current directory


Deploy layer:

    $ aws lambda publish-layer-version \
        --region <region> \
        --layer-name <name> \
        --zip-file fileb://build/weasyprint-layer-python3.12-x86_64.zip

Lambda must be configured with these env vars:

    LD_LIBRARY_PATH="/opt/lib"
    FONTCONFIG_PATH="/opt/fonts"

arm64 is also supported! Use the arm64 zip under Releases or build using "make build/weasyprint-layer-python3.12-arm64.zip"

To build a layer for python3.13 runime use:

    RUNTIME=3.13 make build/weasyprint-layer-python3.13-x86_64.zip

### Docker Lambda

Build layer:

    $ cd weasyprint
    $ make build

Test layer:

    $ make run

    # in another terminal
    $ make test
    # result saved in report.pdf

#### Lambda Function

Simple lambda function [provided](./lambda_function.py),
it requires `BUCKET=<bucket name>` env variable if files stored on s3.

Example payload to print pdf from url and return link to s3:

    {"url": "https://kotify.github.io/cloud-print-utils/samples/report/", "filename": "/path/on/s3/report.pdf"}

Example paylod to print pdf from html and css data and return pdf content encoded as base64:

    {"html": "<html><h1>Header</h1></html>", "css": "h1 { color: red }", "filename": "report.pdf", "return": "base64"}
