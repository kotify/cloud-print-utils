# WeasyPrint AWS Lambda

**WARNING** Native lambda layer can run only legacy WeasyPrint v52, as a workaround you can run your lambda function as a [docker container](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html).

## Native Lambda Layer

Build layer:

    $ make build/weasyprint-layer-python3.8.zip

    # to test your build run
    $ make test.weasyprint

Deploy layer:

    $ aws lambda publish-layer-version \
        --region <region> \
        --layer-name <name> \
        --zip-file fileb://build/weasyprint-layer-python3.8.zip

Environment variables expected by layer:

    GDK_PIXBUF_MODULE_FILE="/opt/lib/loaders.cache"
    FONTCONFIG_PATH="/opt/fonts"
    XDG_DATA_DIRS="/opt/lib"

For python3.9 use instructions: https://github.com/kotify/cloud-print-utils/issues/10#issuecomment-1367774956

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

    {"url": "https://kotify.github.io/cloud-print-utils/samples/report/", "filename": "report.pdf"}

Example paylod to print pdf from html and css data and return pdf content encoded in base64:

    {"html": "<html><h1>Header</h1></html>", "css": "h1 { color: red }", "filename": "report.pdf", "return": "base64"}
