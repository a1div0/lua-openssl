SHELL := /bin/bash

DOWNLOAD_ENDPOINT = download.tarantool.io
DOWNLOAD_USER = tarantool
TARANTOOL_LINUX_BUNDLE_NAME = enterprise/release/linux/x86_64/2.10/tarantool-enterprise-sdk-nogc64-2.10.4-0-r523.linux.x86_64.tar.gz
TARANTOOL_MAC_BUNDLE_NAME = enterprise/release/macos/x86_64/2.10/tarantool-enterprise-sdk-gc64-2.10.4-0-r523.macos.x86_64.tar.gz


build:
	set -ex
	docker build -f ubuntu-20.Dockerfile -t luaopenssl-linux .
	docker run -dit -v ${PWD}:/data --name=opensslbox luaopenssl-linux \
		bash -c "cd /data/deps/lua-openssl && make && chmod 777 openssl.so && rm -rf libopenssl.a"
	docker wait opensslbox
	docker rm opensslbox
	mv ${PWD}/deps/lua-openssl/openssl.so ${PWD}/cryptex/lua-openssl.so

sdk:
	curl -o ./sdk.tar.gz -L https://${DOWNLOAD_USER}:${DOWNLOAD_TOKEN}@${DOWNLOAD_ENDPOINT}/${TARANTOOL_LINUX_BUNDLE_NAME}
	mkdir -p ./sdk && tar -xzvf ./sdk.tar.gz -C ./sdk --strip 1
	rm -f ./sdk.tar.gz

.rocks: sdk
	source ./sdk/env.sh \
	&& tarantoolctl rocks install luacheck --only-server=./sdk/rocks \
	&& tarantoolctl rocks install luatest 0.5.7 --only-server=./sdk/rocks \
	&& tarantoolctl rocks install luacov 0.13.0 --only-server=./sdk/rocks \
	&& tarantoolctl rocks install luacov-reporters 0.1.0 --only-server=./sdk/rocks \
	&& tarantoolctl rocks make cryptex-scm-1.rockspec --only-server=./sdk/rocks

pack:
	source ./sdk/env.sh && \
	tarantoolctl rocks make cryptex-1.0.0-1.rockspec && \
	tarantoolctl rocks pack cryptex

pack.scm:
	source ./sdk/env.sh && \
	tarantoolctl rocks make cryptex-scm-1.rockspec && \
	tarantoolctl rocks pack cryptex

rock: build sdk pack

clean:
	rm -rf .rocks sdk

test: test.lint test.unit ## Запуск всех тестов

test.lint: ## Запуск luacheck
	source ${PWD}/sdk/env.sh \
	&& .rocks/bin/luacheck cryptex/ test/ --max-line-length 200

test.unit: ## Запуск unit тестов
	source ${PWD}/sdk/env.sh && \
	.rocks/bin/luatest -c --coverage && \
	.rocks/bin/luacov -r summary && cat luacov.report.out

test.docker:
	set -ex
	docker build -f test-libssl1.0.Dockerfile -t luaopenssl-test .
	docker run -dit -v ${PWD}:/data --name=openssl-test luaopenssl-test \
		bash -c "cd /data/ && rm -rf .rocks && make .rocks && chmod -R 777 .rocks && make test"
	docker wait openssl-test
	docker logs openssl-test
	docker rm openssl-test
