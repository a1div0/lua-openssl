FROM centos:7

RUN yum -y install epel-release https://repo.ius.io/ius-release-el7.rpm
RUN yum -y update
RUN yum -y install build-essential lua luajit lua-devel openssl-devel
RUN yum -y groupinstall "Development Tools"
