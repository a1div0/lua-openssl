SHELL := /bin/bash

DOWNLOAD_ENDPOINT=download.tarantool.io
DOWNLOAD_USER=tarantool
TARANTOOL_BUNDLE_NAME=enterprise/release/linux/x86_64/2.10/tarantool-enterprise-sdk-nogc64-2.10.4-0-r523.linux.x86_64.tar.gz
TARANTOOL_BUNDLE_NAME_MACOS=enterprise/release/macos/x86_64/2.10/tarantool-enterprise-sdk-gc64-2.10.4-0-r523.macos.x86_64.tar.gz

build:
	set -ex
	docker build -f linux.Dockerfile -t luaopenssl-linux .
	echo ${PWD}
	docker run -dit -v ${PWD}:/data --name=opensslbox luaopenssl-linux bash -c "cd /data/deps/lua-openssl && make && chmod 777 openssl.so && rm -rf libopenssl.a"
	docker wait opensslbox
	docker rm opensslbox
	mv ${PWD}/deps/lua-openssl/openssl.so ${PWD}/openssl/libssl.so

sdk:
	curl -o ./sdk.tar.gz -L https://${DOWNLOAD_USER}:${DOWNLOAD_TOKEN}@${DOWNLOAD_ENDPOINT}/${TARANTOOL_BUNDLE_NAME}
	mkdir -p ./sdk && tar -xzvf ./sdk.tar.gz -C ./sdk --strip 1
	rm -f ./sdk.tar.gz

pack:
	source ./sdk/env.sh && \
	tarantoolctl rocks make openssl-scm-1.rockspec && \
	tarantoolctl rocks pack openssl

rock: build sdk pack

clean:
	rm -rf .rocks sdk
