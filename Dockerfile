#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Dockerfile for docker skeleton (useful for running blackbox binaries, scripts, or Python 3 actions) .
FROM centos:7

ADD requirements.txt /


# Upgrade and install basic Python dependencies.
RUN yum -y install curl unzip epel-release bash perl zip git curl wget openssl ca-certificates sed openssh-client bzip2-devel gcc glibc-devel \
    && yum -y install jq python2-pip python3-pip python3 \
#setuptools upgrade fails
#  && pip install --upgrade pip setuptools six \
  && pip install --no-cache-dir six gevent==1.3.6 flask==1.0.2 \ 
  &&  curl -o saclient.zip -sL "https://cloud.appscan.com/api/SCX/StaticAnalyzer/SAClientUtil?os=linux" \
  &&  unzip saclient.zip && rm -rf saclient.zip && mv SAClientUtil* /usr/local/saclient  \
  &&  yum -y clean all \
  &&  rm -Rf /var/cache/yum \
  &&  pip3 install --no-cache-dir -r requirements.txt

ENV FLASK_PROXY_PORT 8080

RUN mkdir -p /actionProxy/owplatform
ADD actionproxy.py /actionProxy/
ADD owplatform/__init__.py /actionProxy/owplatform/
ADD owplatform/knative.py /actionProxy/owplatform/
ADD owplatform/openwhisk.py /actionProxy/owplatform/

RUN mkdir -p /action
ADD stub.sh /action/exec
RUN chmod +x /action/exec

CMD ["/bin/bash", "-c", "cd actionProxy && python -u actionproxy.py"]
