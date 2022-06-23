
# 1. Настройка выделенного сервера

Ubuntu сервер LTS
Выделенный публичный адрес

## 1.1 настраиваем доступ через SSH с паролем
Генерим SSH
ssh-keygen

находим ssh
cat ~/.ssh/id_rsa.pub

копируем руками, если делаем в yandex cloud, либо загружаем командой
ssh-copy-id username@remote_host

справочно детальная инструкция по ssh ключам
https://losst.ru/avtorizatsiya-po-klyuchu-ssh

## 1.2 проверяем пользователь в группе sudo
sudo whoami

справочно дополнительная информация
https://routerus.com/how-to-add-user-to-sudoers-in-ubuntu/?ysclid=l4qrkz408r569736025

## 1.3 обновляем базовые пакеты

sudo apt update 
sudo apt upgrade -y
sudo apt install python3-pip python3-venv git -y

Установка утилиты для скачивания файлов
sudo apt install curl

## 1.4 Устанавливаем Docker и docker-compose
по установке лучше обратиться к документации и поставить все руками. в репозитории ubuntu может быть “битый” дистрибутив.

https://docs.docker.com/engine/install/ubuntu/

установка docker-compose
https://docs.docker.com/compose/install/compose-plugin/#install-the-plugin-manually

проверяем что у нас последние версии. докер должен исполняться от имени супер пользователи, всегда добавляем sudo перед командами.

sudo systemctl status docker 
docker -v
docker compose -v

## 1.5 Полезные команды при работе с docker

Посмотреть контейнеры, образы и volume
docker ps
docker image ls
docker volume ls
docker volume inspect <volume_name>

посмотреть логи контейнера
docker logs --since=1h <container_id>

подключиться к контейнеру
docker exec -it <container_id> sh

остановить все контейнеры и удалить
docker compose stop
sudo docker compose rm web
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker image ls)


## 1.5 включаем firewall

https://losst.ru/nastrojka-ufw-ubuntu

sudo ufw status
открываем доступ ssh
sudo ufw allow OpenSSH

включаем только после открытия доступа ssh
sudo ufw enable

## 1.6 установка nginx
отключаем службу если будет только один конейнер с nginx
sudo systemctl stop nginx





