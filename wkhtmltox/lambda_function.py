#!/usr/bin/env python
import base64
import os
import shlex
import subprocess


def lambda_handler(event, context):
    filename = event["filename"]
    basename = os.path.basename(filename)
    tmpfile = f"/tmp/{basename}"
    ext = os.path.splitext(basename)[1]
    if ext == ".pdf":
        content_type = "application/pdf"
        binary = "wkhtmltopdf"
    else:
        content_type = f"image/{ext[1:]}"
        binary = "wkhtmltoimage"
    if "inputs" in event:
        for fname, data in event["inputs"].items():
            assert fname.startswith(
                "/tmp/"
            ), "Input files must be places in /tmp/ directory."
            with open(fname, "w") as f:
                f.write(data)
    output = subprocess.check_output([binary, *shlex.split(event["args"]), tmpfile])
    print(output)
    if event.get("return") == "base64":
        with open(tmpfile, "rb") as f:
            data = f.read()
        return {
            "statusCode": 200,
            "headers": {
                "Content-type": content_type,
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
                ExtraArgs={"ContentType": content_type},
            )
        url = s3.generate_presigned_url(
            ClientMethod="get_object",
            Params={"Bucket": bucket, "Key": filename},
            ExpiresIn=3600,
        )
        return {"statusCode": 200, "body": url}
