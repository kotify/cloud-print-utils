import * as cdk from "@aws-cdk/core";
import * as lambda from "@aws-cdk/aws-lambda";
import * as s3 from "@aws-cdk/aws-s3";
import * as path from "path";

export class WkhtmltoxStack extends cdk.Stack {
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

    this.bucket = new s3.Bucket(this, "wkhtmltoxBucket", {
      bucketName: uploadBucketName.valueAsString,
      // documents are stored only for one day
      lifecycleRules: [{ expiration: cdk.Duration.days(1) }],
    });

    this.layer = new lambda.LayerVersion(this, "wkhtmltoxLayer", {
      code: lambda.Code.fromAsset(
        path.join(__dirname, "../../build/wkhtmltox-layer.zip")
      ),
      compatibleRuntimes: [lambda.Runtime.PYTHON_3_8],
      license: "MIT",
      description: "fonts and libs required by wkhtmltox",
    });

    this.fn = new lambda.Function(this, "wkhtmltoxFunction", {
      runtime: lambda.Runtime.PYTHON_3_8,
      functionName: "wkhtmltox-print",
      memorySize: 1000,
      environment: {
        GDK_PIXBUF_MODULE_FILE: "/opt/lib/loaders.cache",
        FONTCONFIG_PATH: "/opt/fonts",
        XDG_DATA_DIRS: "/opt/lib",
        BUCKET: this.bucket.bucketName,
      },
      timeout: cdk.Duration.seconds(30),
      handler: "lambda_function.lambda_handler",
      code: lambda.Code.fromAsset(path.join(__dirname, "../../wkhtmltox")),
      layers: [this.layer],
    });

    this.bucket.grantReadWrite(this.fn);
  }
}
