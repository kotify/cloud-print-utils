# WeasyPrint AWS Lambda

**WARNING** WeasyPrint pinned to v52 until amazon linux has pango updated to v1.44, as a workaround you can pack and run your lambda function as a [docker container](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html).

## Lambda Layer

Build layer:

    $ make build/weasyprint-layer-python3.8.zip

    # for future runtimes, eg: python3.9
    # RUNTIME=python3.9 make build/weasyprint-layer-python3.9.zip

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

## Lambda Function

Simple lambda function [provided](./lambda_function.py),
it requires `BUCKET=<bucket name>` env variable if files stored on s3.

Example payload to print pdf from url and return link to s3:

    {"url": "https://weasyprint.org/samples/report/report.html", "filename": "report.pdf"}

Example paylod to print png from html and css data and return png content encoded in base64:

    {"html": "<html><h1>Header</h1></html>", "css": "h1 { color: red }", "filename": "report.png", "return": "base64"}
