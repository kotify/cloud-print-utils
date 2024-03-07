#!/usr/bin/env python
import subprocess
import logging
import base64
import os

import urllib.request
from functools import partial
import tempfile
from weasyprint import CSS, HTML
import pathlib
from urllib.parse import urlparse
import concurrent.futures
import boto3
import uuid

logger = logging.getLogger(__name__)
s3 = boto3.client("s3")


def gen_pdf_name(tmpdir):
    return tmpdir / f"{uuid.uuid4()}.pdf"


def download(tmpdir, url):
    name = gen_pdf_name(tmpdir)
    urllib.request.urlretrieve(url, name)
    return name


def fetch_attachments(downloader, pdfs):
    if not pdfs:
        return []

    with concurrent.futures.ThreadPoolExecutor(
        max_workers=min(len(pdfs), 6)
    ) as executor:
        return list(executor.map(downloader, pdfs))


def postprocess(tmpdir, document, attachments):
    pdfs = fetch_attachments(partial(download, tmpdir), attachments)
    tmpfile = gen_pdf_name(tmpdir)
    subprocess.check_call(
        [
            "gs",
            "-q",
            "-sDEVICE=pdfwrite",
            "-dPDFSETTINGS=/prepress",
            "-dFIXEDMEDIA",
            "-sPAPERSIZE=a4",
            "-dPDFFitPage",
            "-dAutoRotatePages=/PageByPage",
            "-o",
            f"{tmpfile}",
            document,
            *pdfs,
        ]
    )
    return tmpfile


def lambda_handler(event, context):
    filename = event["filename"]
    attachments = [
        a
        for a in event.get("attachments", [])
        if urlparse(a).path.lower().endswith(".pdf")
    ]
    always_postprocess = event.get("always_postprocess", False)
    return_base64 = event.get("return") == "base64"
    basename = os.path.basename(filename)

    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir = pathlib.Path(tmpdir)
        document = gen_pdf_name(tmpdir)
        if "url" in event:
            HTML(url=event["url"]).write_pdf(target=document)
        else:
            HTML(string=event["html"]).write_pdf(
                target=document,
                stylesheets=[CSS(string=event["css"])] if "css" in event else None,
            )

        if attachments or always_postprocess:
            document = postprocess(tmpdir, document, attachments)
        if return_base64:
            with open(document, "rb") as f:
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
            bucket = os.environ["BUCKET"]
            with open(document, "rb") as f:
                s3.upload_fileobj(
                    f,
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
