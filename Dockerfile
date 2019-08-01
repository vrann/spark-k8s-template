#
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
#

FROM openjdk:8 AS spark-base

ARG SPARK_PATH=.
ARG LAPACK_PATH=lapack-3.8.0
ARG spark_jars=${SPARK_PATH}/jars
ARG k8s_tests=${SPARK_PATH}/kubernetes/tests
COPY ${spark_jars} /opt/spark/jars
COPY ${SPARK_PATH}/bin /opt/spark/bin
COPY ${SPARK_PATH}/sbin /opt/spark/sbin
COPY ${SPARK_PATH}/examples /opt/spark/examples
COPY ${k8s_tests} /opt/spark/tests
COPY ${LAPACK_PATH} /opt/lapack-3.8.0

# Before building the docker image, first build and make a Spark distribution following
# the instructions in http://spark.apache.org/docs/latest/building-spark.html.
# If this docker file is being used in the context of building your images from a Spark
# distribution, the docker build command should be invoked from the top level directory
# of the Spark distribution. E.g.:
# docker build -t spark:latest -f kubernetes/dockerfiles/spark/Dockerfile .

RUN set -ex && \
    apt-get update && \
    apt-get install -y coreutils procps bash libc6-dev libnss3-dev curl vim make gcc gfortran && \
    mkdir -p /opt/spark && \
    mkdir -p /opt/spark/work-dir && \
    touch /opt/spark/RELEASE && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd
    

RUN  ulimit -s unlimited && cd /opt/lapack-3.8.0 && make && cp -rf liblapack.a /usr/local/lib/ && ls -la BLAS


#COPY data /opt/spark/data
COPY spark-k8s-template/run-worker.sh /opt/spark/work-dir/
COPY spark-k8s-template/conf/spark-env.sh /opt/spark/conf/
COPY spark-k8s-template/conf/spark-env.sh /opt/spark/conf/

ENV SPARK_HOME /opt/spark
WORKDIR /opt/spark

FROM spark-base
COPY app/spark-counter_2.11-0.4.jar /opt/spark/data/
