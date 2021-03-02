# wkhtmltopdf AWS Lambda

## Lambda Layer

Build layer:

    $ make build/wkhtmltox-layer.zip

    # to test your build run
    $ make test.wkhtmltox

Keep in mind that you `wkhtmltox` contains both pdf and image rendering
tools, if you need only pdf rendering use `make build/wkhtmltopdf-layer.zip`,
of images `make build/wkhtmltoimage-layer.zip` this will reduce the size
of the layer.

Deploy layer:

    $ aws lambda publish-layer-version \
        --region <region> \
        --layer-name <name> \
        --zip-file fileb://build/wkhtmltox-layer.zip

## Lambda Function

Simple lambda function [provided](./lambda_function.py),
it requires `BUCKET=<bucket name>` env variable if files stored on s3.

Example payload to print grayscaled pdf from url and return content encoded in base64:

    {"args": "--grayscale https://google.com", "filename": "google.pdf", "return": "base64"}

Example paylod to print png from html and return lowquality jpeg content encoded in base64:

    {"args": "--lowquality /tmp/report.html", "inputs": {"/tmp/report.html": "<h1>Header</h1><p>Text</p>"}, "filename": "doc.jpg"}
