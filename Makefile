PLATFORM ?= linux/amd64
RUNTIME ?= 3.12
ARCH ?= x86_64
TEST_FILENAME ?= report.pdf
DOCKER_RUN=docker run --rm --platform=${PLATFORM} -e RUNTIME_VERSION=${RUNTIME}

.PHONY: stack.deploy.weasyprint clean test.start.container test.print.report

all: build/weasyprint-layer-python$(RUNTIME)$(ARCH).zip

build/weasyprint-layer-python$(RUNTIME)-$(ARCH).zip: weasyprint/layer_builder.sh \
    build/fonts-layer.zip \
    | _build
	${DOCKER_RUN} \
	    -v `pwd`/weasyprint:/out \
			--entrypoint "/out/layer_builder.sh" \
	    -t public.ecr.aws/lambda/python:${RUNTIME} 
	mv -f ./weasyprint/layer.zip ./build/weasyprint-layer-python${RUNTIME}${ARCH}-no-fonts.zip
	cd build && rm -rf ./opt && mkdir opt \
	    && unzip fonts-layer.zip -d opt \
	    && unzip weasyprint-layer-python${RUNTIME}${ARCH}-no-fonts.zip -d opt \
	    && cd opt && zip -r9 ../weasyprint-layer-python${RUNTIME}${ARCH}.zip .

build/fonts-layer.zip: fonts/layer_builder.sh | _build
	${DOCKER_RUN} \
	    -v `pwd`/fonts:/out \
	    --entrypoint "/out/layer_builder.sh" \
	    -t public.ecr.aws/lambda/python:${RUNTIME} 
	mv -f ./fonts/layer.zip $@

build/ghostscript-layer.zip: ghostscript/layer_builder.sh | _build
	${DOCKER_RUN} \
	    -v `pwd`/ghostscript:/out \
	    --entrypoint "/out/layer_builder.sh" \
	    -t public.ecr.aws/lambda/python:${RUNTIME} 
	mv -f ./ghostscript/layer.zip $@

stack.diff:
	cd cdk-stacks && npm install && npm run build
	cdk diff --app ./cdk-stacks/bin/app.js --stack PrintStack --parameters uploadBucketName=${BUCKET}

stack.deploy:
	cd cdk-stacks && npm install && npm run build
	cdk deploy --app ./cdk-stacks/bin/app.js --stack PrintStack --parameters uploadBucketName=${BUCKET}

test.start.container: build/weasyprint-layer-python$(RUNTIME)-$(ARCH).zip
	${DOCKER_RUN} \
	    -e FONTCONFIG_PATH="/opt/fonts" \
	    -e LD_LIBRARY_PATH="/opt/lib" \
	    -v `pwd`/weasyprint:/var/task \
	    -v `pwd`/build/opt:/opt \
			-p 9000:8080 \
			public.ecr.aws/lambda/python:${RUNTIME} \
	    lambda_function.lambda_handler

test.print.report:
	which jq
	curl --fail -s -S -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
		-d '{"return": "base64", "filename": "${TEST_FILENAME}", "url": "https://kotify.github.io/cloud-print-utils/samples/report/"}' \
		| tail -1 | jq .body | tr -d '"' | base64 -d > ${TEST_FILENAME}
	@echo "Check ./${TEST_FILENAME}, eg.: xdg-open ${TEST_FILENAME}"


_build:
	@mkdir -p build

clean:
	rm -rf ./build
