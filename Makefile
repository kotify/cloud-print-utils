RUNTIME ?= python3.8
TEST_FILENAME ?= report.pdf

.PHONY: stack.deploy.weasyprint clean test.weasyprint

all: build/weasyprint-layer-$(RUNTIME).zip build/wkhtmltopdf-layer.zip

build/weasyprint-layer-$(RUNTIME).zip: weasyprint/layer_builder.sh \
    build/fonts-layer.zip \
    | _build
	docker run --rm \
	    -v `pwd`/weasyprint:/out \
	    -t lambci/lambda:build-${RUNTIME} \
	    bash /out/layer_builder.sh
	mv -f ./weasyprint/layer.zip ./build/weasyprint-no-fonts-layer.zip
	cd build && rm -rf ./opt && mkdir opt \
	    && unzip fonts-layer.zip -d opt \
	    && unzip weasyprint-no-fonts-layer.zip -d opt \
	    && cd opt && zip -r9 ../weasyprint-layer-${RUNTIME}.zip .

build/fonts-layer.zip: fonts/layer_builder.sh | _build
	docker run --rm \
	    -e INSTALL_MS_FONTS="${INSTALL_MS_FONTS}" \
	    -v `pwd`/fonts:/out \
	    -t lambci/lambda:build-${RUNTIME} \
	    bash /out/layer_builder.sh
	mv -f ./fonts/layer.zip $@

stack.diff:
	cd cdk-stacks && npm install && npm run build
	cdk diff --app ./cdk-stacks/bin/app.js --stack PrintStack --parameters uploadBucketName=${BUCKET}

stack.deploy:
	cd cdk-stacks && npm install && npm run build
	cdk deploy --app ./cdk-stacks/bin/app.js --stack PrintStack --parameters uploadBucketName=${BUCKET}

test.weasyprint:
	docker run --rm \
	    -e GDK_PIXBUF_MODULE_FILE="/opt/lib/loaders.cache" \
	    -e FONTCONFIG_PATH="/opt/fonts" \
	    -e XDG_DATA_DIRS="/opt/lib" \
	    -v `pwd`/weasyprint:/var/task \
	    -v `pwd`/build/opt:/opt \
	    lambci/lambda:${RUNTIME} \
	    lambda_function.lambda_handler \
	    '{"url": "https://kotify.github.io/cloud-print-utils/samples/report/", "filename": "${TEST_FILENAME}", "return": "base64"}' \
	    | tail -1 | jq .body | tr -d '"' | base64 -d > ${TEST_FILENAME}
	@echo "Check ./${TEST_FILENAME}, eg.: xdg-open ${TEST_FILENAME}"


build/wkhtmltox-layer.zip: wkhtmltox/layer_builder.sh \
    build/fonts-layer.zip \
    | _build
	docker run --rm \
	    -v `pwd`/wkhtmltox:/out \
	    -t lambci/lambda:build-${RUNTIME} \
	    bash /out/layer_builder.sh
	mv -f ./wkhtmltox/layer.zip ./build/wkhtmltox-no-fonts-layer.zip
	cd build && rm -rf ./opt && mkdir opt \
	    && unzip fonts-layer.zip -d opt \
	    && unzip wkhtmltox-no-fonts-layer.zip -d opt \
	    && cd opt && zip -r9 ../wkhtmltox-layer.zip .

build/wkhtmltopdf-layer.zip: build/wkhtmltox-layer.zip
	cp build/wkhtmltox-layer.zip $@
	zip -d $@ "bin/wkhtmltoimage"

build/wkhtmltoimage-layer.zip: build/wkhtmltox-layer.zip
	cp build/wkhtmltox-layer.zip $@
	zip -d $@ "bin/wkhtmltopdf"

test.wkhtmltox:
	docker run --rm \
	    -e FONTCONFIG_PATH="/opt/fonts" \
	    -v `pwd`/wkhtmltox:/var/task \
	    -v `pwd`/build/opt:/opt \
	    lambci/lambda:${RUNTIME} \
	    lambda_function.lambda_handler \
	    '{"args": "https://google.com", "filename": "${TEST_FILENAME}", "return": "base64"}' \
	    | tail -1 | jq .body | tr -d '"' | base64 -d > ${TEST_FILENAME}
	@echo "Check ./${TEST_FILENAME}, eg.: xdg-open ${TEST_FILENAME}"


_build:
	@mkdir -p build

clean:
	rm -rf ./build

fonts.list:
	docker run --rm lambci/lambda:build-${RUNTIME} \
	    bash -c "yum search font | grep noarch | grep -v texlive"
