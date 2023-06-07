PLATFORM ?= linux/amd64
ifeq ($(PLATFORM), linux/arm64)
 RIE_BIN=aws-lambda-rie-arm64
else
 RIE_BIN=aws-lambda-rie
endif

${RIE_BIN}/aws-lambda-rie:
	mkdir -p ./${RIE_BIN}
	curl -Lo ./${RIE_BIN}/aws-lambda-rie https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/${RIE_BIN}
	chmod +x ./${RIE_BIN}/aws-lambda-rie

build:
	docker build --tag lambda/weasyprint --platform=${PLATFORM} .

run: build ${RIE_BIN}/aws-lambda-rie
	docker run --rm -v `pwd`/${RIE_BIN}:/aws-lambda -p 9000:8080 \
       --entrypoint "/aws-lambda/aws-lambda-rie" lambda/weasyprint \
			 /usr/local/bin/python -m awslambdaric lambda_function.lambda_handler

test:
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
		-d '{"return": "base64", "filename": "report.pdf", "url": "https://kotify.github.io/cloud-print-utils/samples/report/"}' \
		| jq .body | tr -d '"' | base64 -d > report.pdf
