# Установка необходимого софта в Debian

### Шаг 1. Обновление списков репозиториев

После установки и первой загрузки нам предложат выбрать нашу систему:

![загрузка системы](media/install_debian/install_step_28.png)

Загрузимся под суперпользователем:

![загрузка системы](media/install_debian/install_step_29.png)


Обновим репозитории командой ```apt update```:

![загрузка системы](media/install_debian/install_step_30.png)

### Шаг 2. Обновление списков репозиториев

После этого установим нужные нам приложения командой ```apt install -y sudo ufw docker docker-compose openbox xinit kitty firefox-esr```
