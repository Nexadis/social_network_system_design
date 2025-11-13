BINDIR=${CURDIR}/bin
VENDOR_PROTO=vendor-proto

PROTO_PATH:=proto

PB_REL:="https://github.com/protocolbuffers/protobuf/releases"
PB_ZIP:="protoc-30.2-linux-x86_64.zip"

bindir:
	mkdir -p ${BINDIR}

build: bindir protoc-generate
	echo "build"

.PHONY: vendor-proto/google/protobuf
vendor-proto/google/protobuf:
	git clone -b v28.0 --single-branch -n --depth=1 --filter=tree:0 \
		https://github.com/protocolbuffers/protobuf ${VENDOR_PROTO}/protobuf &&\
	cd ${VENDOR_PROTO}/protobuf &&\
	git sparse-checkout set --no-cone src/google/protobuf &&\
	git checkout
	mkdir -p ${VENDOR_PROTO}/google
	mv ${VENDOR_PROTO}/protobuf/src/google/protobuf ${VENDOR_PROTO}/google
	rm -rf ${VENDOR_PROTO}/protobuf

.PHONY: vendor-proto/google/api
vendor-proto/google/api:
	git clone -b master --single-branch -n --depth=1 --filter=tree:0 \
 		https://github.com/googleapis/googleapis ${VENDOR_PROTO}/googleapis && \
 	cd ${VENDOR_PROTO}/googleapis && \
	git sparse-checkout set --no-cone google/api && \
	git checkout
	mkdir -p  ${VENDOR_PROTO}/google
	mv ${VENDOR_PROTO}/googleapis/google/api ${VENDOR_PROTO}/google
	rm -rf ${VENDOR_PROTO}/googleapis

.PHONY: vendor-proto/protoc-gen-openapiv2/options 
vendor-proto/protoc-gen-openapiv2/options:
	git clone -b main --single-branch -n --depth=1 --filter=tree:0 \
 		https://github.com/grpc-ecosystem/grpc-gateway ${VENDOR_PROTO}/grpc-ecosystem && \
 	cd ${VENDOR_PROTO}/grpc-ecosystem && \
	git sparse-checkout set --no-cone protoc-gen-openapiv2/options && \
	git checkout
	mkdir -p ${VENDOR_PROTO}/protoc-gen-openapiv2
	mv ${VENDOR_PROTO}/grpc-ecosystem/protoc-gen-openapiv2/options ${VENDOR_PROTO}/protoc-gen-openapiv2
	rm -rf ${VENDOR_PROTO}/grpc-ecosystem


.PHONY: vendor-proto/validate
vendor-proto/validate:
	git clone -b main --single-branch --depth=2 --filter=tree:0 \
	https://github.com/bufbuild/protoc-gen-validate ${VENDOR_PROTO}/tmp && \
	cd ${VENDOR_PROTO}/tmp && \
	git sparse-checkout set --no-cone validate &&\
	git checkout
	mkdir -p ${VENDOR_PROTO}/validate
	mv ${VENDOR_PROTO}/tmp/validate vendor-proto/
	rm -rf ${VENDOR_PROTO}/tmp
	rm -rf `find ${VENDOR_PROTO} -type f -not -name "*.proto"`

vendor-rm:
	rm -rf ${VENDOR_PROTO}

vendor-proto: vendor-rm vendor-proto/google/protobuf vendor-proto/google/api vendor-proto/protoc-gen-openapiv2/options vendor-proto/validate
	rm -rf `find ${VENDOR_PROTO} -type f -not -name "*.proto"`
	rm -rf `grep -rL "go_package" ${VENDOR_PROTO}`
	rm -rf `find ${VENDOR_PROTO} -type d -path "*/google/api/*"`

bin-deps:
	@echo "${PB_REL} filename:${PB_ZIP}"
		- test ! -e ${BINDIR}/protoc && \
	curl -L ${PB_REL}/download/v30.2/${PB_ZIP} -o ${PB_ZIP} &&\
	unzip ${PB_ZIP} bin/protoc &&\
	rm ${PB_ZIP} &&\
	GOBIN=${BINDIR} go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1 && \
	GOBIN=${BINDIR} go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2.0 && \
	GOBIN=${BINDIR} go install github.com/envoyproxy/protoc-gen-validate@v1.0.4 &&\
	GOBIN=${BINDIR} go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v2.19.1 && \
	GOBIN=${BINDIR} go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v2.19.1 && \
	GOBIN=${BINDIR} go install github.com/go-swagger/go-swagger/cmd/swagger@v0.30.5

protoc-generate: bin-deps vendor-proto
	mkdir -p api/openapiv2
	mkdir -p pkg/${PROTO_PATH}
	${BINDIR}/protoc \
	-I ${PROTO_PATH} \
	-I ${VENDOR_PROTO} \
	--plugin=protoc-gen-go=${BINDIR}/protoc-gen-go \
	--go_out pkg/${PROTO_PATH} \
	--go_opt paths=source_relative \
	--plugin=protoc-gen-go-grpc=${BINDIR}/protoc-gen-go-grpc \
	--go-grpc_out pkg/${PROTO_PATH} \
	--plugin=protoc-gen-validate=${BINDIR}/protoc-gen-validate \
	--validate_out="lang=go,paths=source_relative:pkg/${PROTO_PATH}" \
	--plugin=protoc-gen-grpc-gateway=${BINDIR}/protoc-gen-grpc-gateway \
  --grpc-gateway_out pkg/${PROTO_PATH} \
  --grpc-gateway_opt logtostderr=true  \
	--grpc-gateway_opt paths=source_relative \
	--grpc-gateway_opt generate_unbound_methods=true \
	--plugin=protoc-gen-openapiv2=${BINDIR}/protoc-gen-openapiv2 \
  --openapiv2_out api/openapiv2 \
	--openapiv2_opt output_format=yaml \
	--openapiv2_opt allow_merge=true,merge_file_name=api \
  --openapiv2_opt logtostderr=true \
	${PROTO_PATH}/api/v1/*.proto
	rm -rf pkg

swagger:
	${BINDIR}/swagger serve ./api/openapiv2/*.swagger.json

