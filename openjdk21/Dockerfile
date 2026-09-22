# syntax=docker/dockerfile:1
ARG BASE_IMAGE=alpine:3.24.1

FROM ${BASE_IMAGE}

ARG OPENJDK_VERSION=21.0.12_p8-r0

LABEL org.opencontainers.image.title="OpenJDK 21 on Alpine Linux" \
      org.opencontainers.image.description="Lightweight OpenJDK 21 container image on Alpine Linux 3.24.1" \
      org.opencontainers.image.version="${OPENJDK_VERSION}" \
      org.opencontainers.image.authors="sutrira" \
      org.opencontainers.image.source="https://github.com/sutrira/docker_hub-projects" \
      org.opencontainers.image.licenses="Apache-2.0 AND GPL-2.0-with-classpath-exception"

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk \
    PATH="/usr/lib/jvm/java-21-openjdk/bin:${PATH}"

RUN apk upgrade --no-cache && \
    apk add --no-cache openjdk21-jdk="${OPENJDK_VERSION}" && \
    rm -rf /var/cache/apk/* /tmp/*

CMD ["/bin/ash"]
