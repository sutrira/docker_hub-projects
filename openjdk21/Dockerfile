# Using alpine v3.24.1

FROM alpine:3.24.1

RUN ["apk", "update"]
RUN ["apk", "upgrade", "--no-cache"]

# Using Open JDK 21.0.12_p8-r0
RUN ["apk", "add", "--no-cache", "openjdk21-jdk=21.0.12_p8-r0"]

CMD ["/bin/ash"]
