RUNTIME ?= python3.8
TEST_FILENAME ?= report.pdf

.PHONY: stack.deploy.weasyprint clean test.weasyprint

build/weasyprint-layer-$(RUNTIME).zip: layers/weasyprint/builder.sh \
    build/cairo-pixbuf-libffi-pango-layer-amazon2.zip \
    build/fonts-layer-amazon2.zip \
    Makefile \
    | _build
	docker run --rm \
	    -v `pwd`/layers/weasyprint:/out \
	    -t lambci/lambda:build-${RUNTIME} \
	    bash /out/builder.sh
	mv -f ./layers/weasyprint/weasyprint.zip ./build/weasyprint-intermediate.zip
	cd build && rm -rf ./opt && mkdir opt \
	    && unzip cairo-pixbuf-libffi-pango-layer-amazon2.zip -d opt \
	    && unzip fonts-layer-amazon2.zip -d opt \
	    && unzip weasyprint-intermediate.zip -d opt \
	    && cd opt && zip -r9 ../weasyprint-layer-${RUNTIME}.zip .

build/fonts-layer-amazon2.zip: layers/fonts/builder.sh Makefile | _build
	docker run --rm \
	    -v `pwd`/layers/fonts:/out \
	    -t lambci/lambda:build-${RUNTIME} \
	    bash /out/builder.sh
	mv -f ./layers/fonts/layer.zip ./build/fonts-layer-amazon2.zip

build/cairo-pixbuf-libffi-pango-layer-amazon2.zip: layers/cairo-pixbuf-libffi-pango/builder.sh Makefile | _build
	docker run --rm \
	    -v `pwd`/layers/cairo-pixbuf-libffi-pango:/out \
	    -t lambci/lambda:build-${RUNTIME} \
	    bash /out/builder.sh
	mv -f ./layers/cairo-pixbuf-libffi-pango/layer.zip ./build/cairo-pixbuf-libffi-pango-layer-amazon2.zip

stack.diff.weasyprint:
	cd cdk-stacks && npm install && npm run build
	cdk diff --app ./cdk-stacks/bin/app.js --stack WeasyPrintStack --parameters uploadBucketName=${BUCKET}

stack.deploy.weasyprint:
	cd cdk-stacks && npm install && npm run build
	cdk deploy --app ./cdk-stacks/bin/app.js --stack WeasyPrintStack --parameters uploadBucketName=${BUCKET}

test.weasyprint:
	docker run --rm  -it \
	    -e GDK_PIXBUF_MODULE_FILE="/opt/lib/loaders.cache" \
	    -e FONTCONFIG_PATH="/opt/fonts" \
	    -e XDG_DATA_DIRS="/opt/lib" \
	    -v `pwd`/weasyprint:/var/task \
	    -v `pwd`/build/opt:/opt \
	    lambci/lambda:${RUNTIME} \
	    lambda_function.lambda_handler \
	    '{"url": "https://weasyprint.org/samples/report/report.html", "filename": "${TEST_FILENAME}", "return": "base64"}' \
	    | tail -1 | jq .body | tr -d '"' | base64 -d > ${TEST_FILENAME}
	@echo "Check ./report.pdf, eg.: xdg-open report.pdf"

_build:
	@mkdir -p build

clean:
	rm -rf ./build
