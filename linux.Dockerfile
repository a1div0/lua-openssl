FROM ubuntu:20.04

ENV BUILD_DIR="/data"

RUN apt-get update -y
RUN apt install -y build-essential
RUN apt install -y lua5.3
RUN apt-get install -y luajit libluajit-5.1-dev libssl-dev
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -yq pkg-config
