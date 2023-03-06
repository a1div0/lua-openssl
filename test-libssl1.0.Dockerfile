FROM centos:7

RUN yum -y install epel-release https://repo.ius.io/ius-release-el7.rpm
RUN yum update -y
RUN yum -y install make
RUN yum -y install openssl-devel
