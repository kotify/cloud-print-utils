# WeasyPrint AWS Lambda

**WARNING** Native lambda layer can run only legacy WeasyPrint v52, as a workaround you can run your lambda function as a [docker container](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html).

## Docker Lambda

Build Image:

    $ cd weasyprint
    $ make build

You can choose to build your image for linux/amd64 (default) or linux/arm64 (update the PLATFORM variable in Makefile)

Test Image:

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
