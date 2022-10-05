# Файловый сервер vsftpd

Итак, парни, как мы помним из pipex-а, файлы, наряду с процессами - это базовые абстракции linux.

![настройка vsftpd](media/stickers/files.png)

В проекте inception же эти знания нам не пригодятся!

Давайте же будем радоваться тому, что нам не нужно погружаться в низкоуровневое программирование! Ведь всё, что нам сейчас нужно - это всего лишь написать контейнер, содержащий в себе файловый сервер для работы с разделом wordpress. А не эти ваши потоки ввода-вывода...

## Шаг 1. Создание Dockerfile

Как обычно, начинаем с Dockerfile


https://github.com/fikipollo/vsftpd-docker/blob/master/Dockerfile


## Шаг 2. Создание точки входа

На примере этого контейнера я нарушу традицию, сложившуюся в этом гайде, и припишу команду запуска не в CMD, а в скриптовом файле, который запущу в CMD. Этот файл и будет точкой входа, через которую запустится наш проект.

Как мы помним, инструкция RUN создаёт статичный слой, а CMD или ENTRYPOINT делают его контейнером - запускают сервис (или в редких случаях несколько сервисов) внутри него, заставляя контейнер исполнятся в оперативной памяти.

Образ становится контейнером, если в CMD или ENTRYPOINT прописан запуск какой-либо службы. Если же там прописана только команда, контейнер выполняет команду и тут же умирает. Но так же мы можем миксовать эти возможности - исполнять команды через скрипт, и в нём же запускать нашу службу, которая будет точкой входа.

Напишем скрипт, который это делает:

```
#!/bin/sh

addgroup -g $FTP_UID -S $FTP_USER
if [[ "$FTP_HOME" != "default" ]]; then
  adduser -u $FTP_UID -D -G $FTP_USER -h $FTP_HOME -s /bin/false  $FTP_USER
  chown $FTP_USER:$FTP_USER $FTP_HOME -R
else
  adduser -u $FTP_UID -D -G $FTP_USER -h /home/$FTP_USER -s /bin/false  $FTP_USER
  chown $FTP_USER:$FTP_USER /home/$FTP_USER/ -R
fi

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
```