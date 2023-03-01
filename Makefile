build:
	docker build -f Dockerfile.linux -t luaopenssl .
	docker run -itd -v $PWD:/data luaopenssl bash