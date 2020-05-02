import * as cdk from "@aws-cdk/core";
import * as lambda from "@aws-cdk/aws-lambda";
import * as s3 from "@aws-cdk/aws-s3";
import * as path from "path";

export class WeasyPrintStack extends cdk.Stack {
  bucket: s3.IBucket;
  fn: lambda.IFunction;
  layer: lambda.ILayerVersion;

  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const uploadBucketName = new cdk.CfnParameter(this, "uploadBucketName", {
      type: "String",
      description:
        "The name of the Amazon S3 bucket where uploaded files will be stored.",
    });

    this.bucket = new s3.Bucket(this, "WeasyprintBucket", {
      bucketName: uploadBucketName.valueAsString,
      lifecycleRules: [{ expiration: cdk.Duration.days(1) }],
    });

    this.layer = new lambda.LayerVersion(this, "weasyprintLayer", {
      code: lambda.Code.fromAsset(
        path.join(__dirname, "../../build/weasyprint-layer-python3.8.zip")
      ),
      compatibleRuntimes: [lambda.Runtime.PYTHON_3_8],
      license: "MIT",
      description: "fonts and libs required by weasyprint",
    });

    this.fn = new lambda.Function(this, "weasyprintFunction", {
      runtime: lambda.Runtime.PYTHON_3_8,
      functionName: "weasyprint-print",
      memorySize: 1000,
      environment: {
        GDK_PIXBUF_MODULE_FILE: "/opt/lib/loaders.cache",
        FONTCONFIG_PATH: "/opt/fonts",
        XDG_DATA_DIRS: "/opt/lib",
        BUCKET: this.bucket.bucketName,
      },
      timeout: cdk.Duration.seconds(30),
      handler: "lambda_function.lambda_handler",
      code: lambda.Code.fromAsset(path.join(__dirname, "../../weasyprint")),
      layers: [this.layer],
    });

    this.bucket.grantReadWrite(this.fn);
  }
}
