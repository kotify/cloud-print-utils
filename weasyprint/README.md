# WeasyPrint AWS Lambda

## Native layer

Build layer:

    $ make build/weasyprint-layer-python3.12.zip

    # to test your build run
    $ make test.weasyprint

Deploy layer:

    $ aws lambda publish-layer-version \
        --region <region> \
        --layer-name <name> \
        --zip-file fileb://build/weasyprint-layer-python3.12.zip

Lambda must be configured with these env vars:

    GDK_PIXBUF_MODULE_FILE="/opt/lib/loaders.cache"
    FONTCONFIG_PATH="/opt/fonts"
    XDG_DATA_DIRS="/opt/lib"

## Docker Lambda

Build layer:

    $ cd weasyprint
    $ make build

Test layer:

    $ make run

    # in another terminal
    $ make test
    # result saved in report.pdf

## Lambda Function

Simple lambda function [provided](./lambda_function.py),
it requires `BUCKET=<bucket name>` env variable if files stored on s3.

Example payload to print pdf from url and return link to s3:

    {"url": "https://kotify.github.io/cloud-print-utils/samples/report/", "filename": "/path/on/s3/report.pdf"}

Example paylod to print pdf from html and css data and return pdf content encoded as base64:

    {"html": "<html><h1>Header</h1></html>", "css": "h1 { color: red }", "filename": "report.pdf", "return": "base64"}
