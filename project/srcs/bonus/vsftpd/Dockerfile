FROM alpine:3.16

RUN apk update && apk upgrade && \
    apk add --no-cache vsftpd

EXPOSE 21

CMD [ "/usr/sbin/vsftpd" ]