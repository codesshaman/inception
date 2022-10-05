FROM alpine:3.16

ENV FTP_USER=ftpuser \
    FTP_PASS=supersecret \
    FTP_HOME=default \
    FTP_UID=1000 \
    ONLY_UPLOAD=NO \
    ONLY_DOWNLOAD=NO \
    PASV_ENABLE=NO \
    PASV_ADDRESS=yourserveradress.com \
    PASV_MIN=21100 \
    PASV_MIN=21100 \
    UMASK=022

RUN apk update && apk upgrade && \
    apk add --no-cache vsftpd nano

COPY bonus/vsftpd/conf/entrypoint.sh /usr/sbin/

RUN echo "local_enable=YES" >> /etc/vsftpd/vsftpd.conf && \
  echo "chroot_local_user=YES" >> /etc/vsftpd/vsftpd.conf && \
  echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf && \
  echo "background=NO" >> /etc/vsftpd/vsftpd.conf && \
  echo "dirmessage_enable=YES" >> /etc/vsftpd/vsftpd.conf && \
  echo "max_clients=10" >> /etc/vsftpd/vsftpd.conf && \
  echo "max_per_ip=5" >> /etc/vsftpd/vsftpd.conf && \
  echo "write_enable=YES" >> /etc/vsftpd/vsftpd.conf && \
  echo "passwd_chroot_enable=yes" >> /etc/vsftpd/vsftpd.conf && \
  echo "listen_ipv6=NO" >> /etc/vsftpd/vsftpd.conf && \
  echo "seccomp_sandbox=NO" >> /etc/vsftpd/vsftpd.conf && \
  sed -i "s/anonymous_enable=YES/anonymous_enable=NO/" /etc/vsftpd/vsftpd.conf && \
  cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf_or && \
  chmod +x /usr/sbin/entrypoint.sh

EXPOSE 21

CMD [ "/usr/sbin/entrypoint.sh" ]