# AWS Lambda to print pdfs

## WeasyPrint

[WeasyPrint](https://weasyprint.org/) is python based pdf/png print service.

### Lambda Layer

To build a layer you need **docker** installed on your system.
This layer supports only amazon linux 2 runtimes.

Build layer:

    $ make build/weasyprint-layer-python3.8.zip

    # for future runtimes, eg: python3.9
    # RUNTIME=python3.9 make build/weasyprint-layer-python3.9.zip

    # to test your build run
    $ make test.weasyprint

Deploy layer (see below for full stack deployment):

    $ aws lambda publish-layer-version \
        --region <region> \
        --layer-name <name> \
        --zip-file fileb://build/weasyprint-layer-python3.8.zip

Environment variables expected by layer:

    GDK_PIXBUF_MODULE_FILE="/opt/lib/loaders.cache"
    FONTCONFIG_PATH="/opt/fonts"
    XDG_DATA_DIRS="/opt/lib"

### Lambda Function

Simple lambda function [provided](weasyprint/lambda_function.py), it requires `BUCKET=<bucket name>` env variable if files stored on s3.

Example payload to print pdf from url and return link to s3:

    {"url": "https://weasyprint.org/samples/report/report.html", "filename": "report.pdf"}

Example paylod to print png from html and css data and return png content encoded in base64:

    {"html": "<html><h1>Header</h1></html>", "css": ["h1 { color: red }"], "filename": "report.png", "return": "base64"}

### CloudFormatin Deployment

**WARNING** review [code](cdk-stacks/lib/weasyprint-stack.ts) before deployment.

Stack includes: printer lambda function and s3 bucket where files are stored.

We use [CDK](https://docs.aws.amazon.com/cdk/latest/guide/home.html) to deploy stack, thus you need nodejs installed to run it:

    # build
    $ cd cdk-stacks && npm install && npm run build
    # view diff
    $ cdk diff --stack WeasyPrintStack --parameters uploadBucketName=<bucket name>
    # deploy
    $ cdk deploy --stack WeasyPrintStack --parameters uploadBucketName=<bucket name>

To test your deployment:

    # invoke function
    $ aws lambda invoke --function-name weasyprint-print \
        --payload '{"url": "https://weasyprint.org/samples/report/report.html", "filename": "report.pdf"}' \
        --log-type Tail --query 'LogResult' --output text out | base64 -d

    # view output
    $ cat out
    {"statusCode": 200, "body": "https://your-bucket.s3.amazonaws.com/report.pdf?signature..."}

    # open in browser
    $ chromium-browser $(cat out | jq .body | tr -d '"')
