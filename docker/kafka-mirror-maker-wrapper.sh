#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# https://cwiki.apache.org/confluence/display/KAFKA/KIP-3+-+Mirror+Maker+Enhancement
# https://community.hortonworks.com/articles/79891/kafka-mirror-maker-best-practices.html

CONSUMER_GROUP_ID="${CONSUMER_GROUP_ID:-mirror-maker-handler}"
DEFAULT_OFFSET_RESET="largest"
NUM_STREAMS="${NUM_STREAMS:-1}"
NUM_PRODUCERS="${NUM_PRODUCERS:-1}"
WHITELIST="${WHITELIST:-event_topic}"
DEFAULT_MSG_HANDLER_ARGS="\"project\":\"project_id"
KAFKA_BIN_DIR=$(dirname $0)
KAFKA_DIR=$(dirname ${KAFKA_BIN_DIR})

if [ -n "${BLACK_LIST}" ]; then
    BLACK_LIST="--blacklist ${BLACK_LIST}"
fi

sed -i "s/^group.id=.*/group.id=${CONSUMER_GROUP_ID}/g" ${KAFKA_DIR}/config/consumer.properties

if [ -z "${MSG_HANDLER}" ]; then
    MSG_HADNLER="--message.handler ${DEFAULT_MSG_HANDLER}"
fi

if [ -z "${MSG_HANDLER_ARGS}" ]; then
    MSG_HANDLER_ARGS="--message.handler.args ${DEFAULT_MSG_HANDLER_ARGS}"
fi

#if [ -z "${CONSUMER_BOOTSTRAP_SERVERS}" ]; then
#    echo "Specify CONSUMER_BOOTSTRAP_SERVERS connection string"
#    exit 2
#fi

if [ -z "${ZOOKEEPER_CONNECT}" ]; then
    echo "Specify ZOOKEEPER_CONNECT connection string"
    exit 2
fi

sed -i "s/^zookeeper.connect=.*/zookeeper.connect=${ZOOKEEPER_CONNECT}/g" ${KAFKA_DIR}/config/consumer.properties
#sed -i "/^bootstrap.servers/d" ${KAFKA_DIR}/config/consumer.properties
#echo "zookeeper.connect=${ZOOKEEPER_CONNECT}" >> ${KAFKA_DIR}/config/consumer.properties
# timeout in ms for connecting to zookeeper
#echo "zookeeper.connection.timeout.ms=6000" >> ${KAFKA_DIR}/config/consumer.properties
echo "partition.assignment.strategy=roundrobin" >> ${KAFKA_DIR}/config/consumer.properties

if [ -z "${OFFSET_RESET}" ]; then
    OFFSET_RESET=${DEFAULT_OFFSET_RESET}
fi

echo "auto.offset.reset=${OFFSET_RESET}" >> ${KAFKA_DIR}/config/consumer.properties
#echo "auto.commit.enabled=false" >> ${KAFKA_DIR}/config/consumer.properties
#echo "auto.commit.enabled=true" >> ${KAFKA_DIR}/config/consumer.properties

if [ -z "${PRODUCER_BOOTSTRAP_SERVERS}" ]; then
    echo "Specify PRODUCER_BOOTSTRAP_SERVERS"
    exit 3
fi

# producer.properties
#sed -i "s/^bootstrap.servers=.*/bootstrap.servers=${PRODUCER_BOOTSTRAP_SERVERS}/g" ${KAFKA_DIR}/config/newproducer.properties

#cat >> ${KAFKA_DIR}/config/newproducer.properties << EOF
#max.in.flight.requests.per.connection=1
#retries=65536
#acks=all
#block.on.buffer.full=true
#EOF

sed -i "s/^metadata.broker.list=.*/metadata.broker.list=${PRODUCER_BOOTSTRAP_SERVERS}/g" ${KAFKA_DIR}/config/producer.properties
# echo "bootstrap.servers=${PRODUCER_BOOTSTRAP_SERVERS}" >> ${KAFKA_DIR}/config/producer.properties
# cat ${KAFKA_DIR}/config/producer.properties

exec ${KAFKA_BIN_DIR}/kafka-mirror-maker.sh \
  --consumer.config ${KAFKA_DIR}/config/consumer.properties \
  --producer.config ${KAFKA_DIR}/config/producer.properties \
  --num.streams ${NUM_STREAMS} \
  --num.producers ${NUM_PRODUCERS} \
  --whitelist ${WHITELIST} \
  ${BLACK_LIST} \
  ${MSG_HANDLER_ARGS}
