#!/usr/bin/env python
import base64
import os

from weasyprint import CSS, HTML


def lambda_handler(event, context):
    filename = event["filename"]
    basename = os.path.basename(filename)
    tmpfile = f"/tmp/{basename}"
    if "url" in event:
        HTML(url=event["url"]).write_pdf(target=tmpfile)
    else:
        HTML(string=event["html"]).write_pdf(
            target=tmpfile,
            stylesheets=[CSS(string=event["css"])] if "css" in event else None,
        )
    if event.get("return") == "base64":
        with open(tmpfile, "rb") as f:
            data = f.read()
        return {
            "statusCode": 200,
            "headers": {
                "Content-type": "application/pdf",
                "Content-Disposition": f"attachment;filename={basename}",
            },
            "isBase64Encoded": True,
            "body": base64.b64encode(data).decode("utf-8"),
        }
    else:
        import boto3

        s3 = boto3.client("s3")
        bucket = os.environ["BUCKET"]
        with open(tmpfile, "rb") as f:
            s3.upload_fileobj(
                open(tmpfile, "rb"),
                bucket,
                filename,
                ExtraArgs={"ContentType": "application/pdf"},
            )
        url = s3.generate_presigned_url(
            ClientMethod="get_object",
            Params={"Bucket": bucket, "Key": filename},
            ExpiresIn=3600,
        )
        return {"statusCode": 200, "body": url}
