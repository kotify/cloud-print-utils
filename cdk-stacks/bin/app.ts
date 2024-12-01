#!/usr/bin/env node
import "source-map-support/register";
import * as cdk from "@aws-cdk/core";
import { WeasyPrintStack } from "../lib/weasyprint-stack";

const app = new cdk.App();
new WeasyPrintStack(app, "WeasyPrintStack");
