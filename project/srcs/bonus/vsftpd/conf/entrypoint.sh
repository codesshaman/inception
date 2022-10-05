#!/bin/sh

#CREATE THE USER AND THE HOME FOLDER
addgroup -g $FTP_UID -S $FTP_USER
if [[ "$FTP_HOME" != "default" ]]; then
  adduser -u $FTP_UID -D -G $FTP_USER -h $FTP_HOME -s /bin/false  $FTP_USER
  chown $FTP_USER:$FTP_USER $FTP_HOME -R
else
  adduser -u $FTP_UID -D -G $FTP_USER -h /home/$FTP_USER -s /bin/false  $FTP_USER
  chown $FTP_USER:$FTP_USER /home/$FTP_USER/ -R
fi

#UPDATE PASSWORD
echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd

cp /etc/vsftpd/vsftpd.conf_or /etc/vsftpd/vsftpd.conf

if [[ "$PASV_ENABLE" == "YES" ]]; then
  echo "PASV is enabled"
  echo "pasv_enable=YES" >> /etc/vsftpd/vsftpd.conf
  echo "pasv_max_port=$PASV_MAX" >> /etc/vsftpd/vsftpd.conf
  echo "pasv_min_port=$PASV_MIN" >> /etc/vsftpd/vsftpd.conf
  echo "pasv_address=$PASV_ADDRESS" >> /etc/vsftpd/vsftpd.conf
else
  echo "pasv_enable=NO" >> /etc/vsftpd/vsftpd.conf
fi

echo "local_umask=$UMASK" >> /etc/vsftpd/vsftpd.conf

/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf