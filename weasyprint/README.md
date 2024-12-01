# WeasyPrint AWS Lambda

## Native layer

Build layer:

    # dependencies - ensure your environment has unzip, zip, and jq

    $ make build/weasyprint-layer-python3.12.zip

    # to test your build run
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
        --zip-file fileb://build/weasyprint-layer-python3.12.zip

Lambda must be configured with these env vars:

    GDK_PIXBUF_MODULE_FILE="/opt/lib/loaders.cache"
    FONTCONFIG_PATH="/opt/fonts"
    XDG_DATA_DIRS="/opt/lib"

If you are using the release zip files ensure your Lambda instruction set architecture is set to `x86_64` and not `arm64`.


To build a layer for python 3.13 use:

    RUNTIME=3.13 make build/weasyprint-layer-python3.13.zip

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
