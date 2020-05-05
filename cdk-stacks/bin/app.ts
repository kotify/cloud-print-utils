#!/usr/bin/env node
import "source-map-support/register";
import * as cdk from "@aws-cdk/core";
import { WeasyPrintStack } from "../lib/weasyprint-stack";
import { WkhtmltoxStack } from "../lib/wkhtmltox-stack";

const app = new cdk.App();
new WeasyPrintStack(app, "WeasyPrintStack");
new WkhtmltoxStack(app, "WkhtmltoxStack");
