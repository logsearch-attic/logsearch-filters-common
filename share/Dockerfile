FROM ubuntu:precise
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install openjdk-7-jre-headless curl build-essential

ADD . /docker
WORKDIR /docker

RUN cd vendor/logstash && make vendor-jruby && bin/logstash deps

ENV PATH=/docker/bin:/docker/vendor/logsearch-filters-common/bin:$PATH
ENTRYPOINT [ "/docker/vendor/logsearch-filters-common/bin/runner.sh" ]
