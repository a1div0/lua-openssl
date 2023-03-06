FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y
RUN apt install -y build-essential lua5.3 cmake
RUN apt-get install -y luajit libluajit-5.1-dev libssl-dev
RUN apt-get install -yq pkg-config
