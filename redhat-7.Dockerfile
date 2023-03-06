# docker pull registry.access.redhat.com/rhel7:7.9-924
FROM registry.access.redhat.com/rhel7:7.9-924

RUN yum -y update
RUN yum -y install build-essential lua luajit lua-devel openssl-devel
RUN yum -y groupinstall "Development Tools"
