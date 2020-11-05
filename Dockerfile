FROM golang:1.14
ARG GOARCH=amd64
WORKDIR /go/src/github.com/GoogleContainerTools/kaniko

# Add .docker config dir
RUN mkdir -p /kaniko/.docker

COPY . .
RUN make GOARCH=${GOARCH}

FROM centos:8

COPY --from=0 /go/src/github.com/GoogleContainerTools/kaniko/out/executor /kaniko/executor
COPY files/ca-certificates.crt /kaniko/ssl/certs/
COPY --from=0 /kaniko/.docker /kaniko/.docker
COPY files/nsswitch.conf /etc/nsswitch.conf
ENV HOME /root
ENV USER root
ENV PATH /usr/local/bin:/usr/bin:/usr/local/bin:/kaniko
ENV SSL_CERT_DIR=/kaniko/ssl/certs
ENV DOCKER_CONFIG /kaniko/.docker/

COPY config.json /kaniko/.docker/ 
CMD ["/kaniko/executor"]
