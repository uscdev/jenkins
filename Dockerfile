# Create Jenkins image with USC plugins and utilities such as docker

FROM jenkinsci/jenkins

USER root
RUN apt-get update && apt-get -y upgrade
RUN mv /etc/localtime /etc/localtime-old && ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
USER jenkins

RUN /usr/local/bin/install-plugins.sh \
mailer cloudbees-folder timestamper \
workflow-aggregator \
ldap subversion \
dependency-check-jenkins-plugin git-client git \
github-branch-source github-organization-folder ssh-slaves pam-auth \
antisamy-markup-formatter ws-cleanup ant matrix-auth credentials-binding gradle pipeline-stage-view \
build-timeout docker-build-publish docker-custom-build-environment google-play-android-publisher \
docker-traceability \
docker-workflow \
docker-plugin docker-build-step saml \
file-operations nexus-artifact-uploader \
pipeline-utility-steps \
pipeline-model-definition \
job-dsl envinject simple-theme config-file-provider \
email-ext

USER root
RUN apt-get install -y --no-install-recommends \
     apt-transport-https \
     ca-certificates \
     python \
     python-pip \
     curl \
     software-properties-common \
     packagekit \
     build-essential \
     python-setuptools

RUN pip install awscli

RUN curl -fsSL https://apt.dockerproject.org/gpg | apt-key add - && \
add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       debian-$(lsb_release -cs) \
       main" && \
apt-get update && apt-get -y install docker-engine && \
usermod -aG docker jenkins && \
cd /usr/local/ && \
curl -L -O http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && \
tar xf android-sdk_r24.4.1-linux.tgz

ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV ANDROID_SDK /usr/local/android-sdk-linux
ENV ANDROID_SDK_COMPONENTS tools,platform-tools,android-23,build-tools-23.0.2,sys-img-armeabi-v7a-android-23,extra-android-m2repository,extra-google-m2repository

RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter tools --no-ui --force -a && \
echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter platform-tools --no-ui --force -a && \
echo y | /usr/local/android-sdk-linux/tools/android update sdk --no-ui --all --filter "${ANDROID_SDK_COMPONENTS}" --force

RUN mkdir -p ${ANDROID_HOME}/licenses
RUN echo -e "8933bad161af4178b1185d1a37fbf41ea5269c55\c" > ${ANDROID_HOME}/licenses/android-sdk-license
RUN echo -e "79120722343a6f314e0719f863036c702b0e6b2a\n84831b9409646a918e30573bab4c9c91346d8abd\c" > ${ANDROID_HOME}/licenses/android-sdk-preview-license
RUN echo -e "8403addf88ab4874007e1c1e80a0025bf2550a37\c" > ${ANDROID_HOME}/licenses/intel-android-sysimage-license


USER jenkins
ENV DOCKER_HOST tcp://dcorley-swarm-mgr01.usc.edu:2376
ENV DOCKER_TLS_VERIFY=1
ENV DOCKER_CERT_PATH=/run/secrets

ENV AWS_DEFAULT_REGION us-west-1
