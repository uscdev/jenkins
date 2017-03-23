FROM jenkins:latest

# COPY plugins.txt /usr/share/jenkins/plugins.txt
# RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/install-plugins.sh \
mailer cloudbees-folder timestamper workflow-aggregator ldap subversion \
dependency-check-jenkins-plugin git-client git \
github-branch-source github-organization-folder ssh-slaves pam-auth email-ext \
antisamy-markup-formatter ws-cleanup ant matrix-auth credentials-binding gradle pipeline-stage-view \
build-timeout docker-build-publish docker-custom-build-environment docker-traceability docker-workflow \
docker-plugin docker-build-step saml \
file-operations nexus-artifact-uploader pipeline-utility-steps pipeline-model-definition

USER root
RUN apt-get update
#      && apt-get -y upgrade

RUN apt-get install -y --no-install-recommends \
     apt-transport-https \
     ca-certificates \
     curl \
     software-properties-common

RUN curl -fsSL https://apt.dockerproject.org/gpg | apt-key add -

RUN add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       debian-$(lsb_release -cs) \
       main"

RUN apt-get update

RUN apt-get -y install docker-engine

RUN usermod -aG docker jenkins

USER jenkins
ENV DOCKER_HOST tcp://dcorley-swarm-mgr01.usc.edu:2376
ENV DOCKER_TLS_VERIFY=1
ENV DOCKER_CERT_PATH=/run/secrets
