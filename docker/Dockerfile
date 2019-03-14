FROM billryan/jdk:8

LABEL maintainer="yuanbin2014@gmail.com"

ADD kafka_2.10-0.8.2.2.tgz /usr/local/
RUN mv /usr/local/kafka_2.10-0.8.2.2 /usr/local/kafka
COPY kafka-mirror-maker-wrapper.sh /usr/local/kafka/bin/

WORKDIR /usr/local/kafka

ENTRYPOINT ["bin/kafka-mirror-maker-wrapper.sh"]

CMD []
