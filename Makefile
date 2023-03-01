build:
	set -ex
	docker build -f linux.Dockerfile -t luaopenssl-linux .
	echo ${PWD}
	docker run -dit -v ${PWD}:/data --name=opensslbox luaopenssl-linux bash -c "cd /data/deps/lua-openssl && make && chmod 777 openssl.so && rm -rf libopenssl.a"
	docker wait opensslbox
	docker rm opensslbox
	mv ${PWD}/deps/lua-openssl/openssl.so ${PWD}/openssl.so
