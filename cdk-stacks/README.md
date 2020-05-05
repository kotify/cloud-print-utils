# Infrastructure as Code example

We use [CDK](https://docs.aws.amazon.com/cdk/latest/guide/home.html) to deploy stack, thus you need nodejs installed to run it.

Each stack consist of printer lambda function, layer and s3 bucket where files are stored.
You must build layer before running deploy.

We provide two stacks `WeasyPrintStack` and `WkhtmltoxStack`, below is deployment
example of WeasyPrintStack.

**WARNING** review code before deployment.

    # build (rebuild must be done on every change in typescript files)
    $ cd cdk-stacks && npm install && npm run build

    # view diff WeasyPrintStack
    $ npm run cdk diff WeasyPrintStack

    # deploy WeasyPrintStack
    $ npm run cdk deploy WeasyPrintStack --parameters uploadBucketName=<bucket name>

    # generate synthesized CloudFormation template
    $ npm run cdk synth WeasyPrintStack

To test your deployment:

    # invoke function
    $ aws lambda invoke --function-name cloud-print \
        --payload '{"url": "https://weasyprint.org/samples/report/report.html", "filename": "report.pdf"}' \
        --log-type Tail --query 'LogResult' --output text out | base64 -d

    # view output
    $ cat out
    {"statusCode": 200, "body": "https://your-bucket.s3.amazonaws.com/report.pdf?signature..."}

    # open in browser
    $ chromium-browser $(cat out | jq .body | tr -d '"')
