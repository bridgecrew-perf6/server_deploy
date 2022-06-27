##########################################################
#https://habr.com/ru/post/318952/
#установим nginx
sudo apt-get update
sudo apt-get install nginx

# Remove the default nginx website and associated configs.
sudo rm -rf /var/www/html
sudo rm -rf /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

#проверим папки, в них ничего не должно быть, особеннов в enambled 
sudo ls /etc/nginx/sites-available/
sudo ls /etc/nginx/sites-enabled/

#скопируем глобальные настройки nginx (файлы конфигураций из архива)
#Подготовим nginx к получению сертификатов
sudo cp ./etc/nginx/acme /etc/nginx/acme
sudo cp ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
sudo cp ./etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# Restart nginx because we changed the config files.
sudo service nginx restart
#мы закончили только глобальные настройки nginx, в конце еще сделать
#подключение сайтов

##########################################################
#удалить папку с настройками letsencrypt
sudo rm -rf /etc/letsencrypt/

#установим cebot
#https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot python-certbot-nginx

#установим cebot Ubuntu 20.04 LTS
#https://certbot.eff.org/lets-encrypt/ubuntufocal-nginx
#удалим прошлую версию
sudo apt-get remove certbot
#установим через snap
sudo snap install --classic certbot



# Create the Let's Encrypt / ACME challenge path.
sudo rm -rf /var/www/letsencrypt/.well-known/acme-challenge
sudo mkdir -p /var/www/letsencrypt/.well-known/acme-challenge
#создадим файл с тестовой страницей для проверки доступности сервиса из вне
echo 'Success ACME challenge directory working outside' > /var/www/letsencrypt/.well-known/acme-challenge/test.html

# создадим файл с настройкам для cerbot (копируем из папки архива)
sudo cp /etc/letsencrypt/cli.ini /etc/letsencrypt/cli.ini

#Регистрация в Let's Encrypt нужно сделать один раз
#Вставьте правильную почту!
certbot register --email auxlink.com@gmail.com

# Create a DHParam file. Use 4096 bits instead of 2048 bits in production.
sudo openssl dhparam -out /etc/letsencrypt/live/dhparam.pem 4096

# Restart nginx because we changed the config files.
sudo service nginx restart

#проверим что наш тестовый файл виден:
#лучше проделать для каждого домена чтобы проверить работу nginx
curl -L http://hub.auxlink.com/.well-known/acme-challenge/test.html
curl -L http://wiki.auxlink.com/.well-known/acme-challenge/test.html
curl -L http://jira.auxlink.com/.well-known/acme-challenge/test.html
curl -L http://demo.auxlink.com/.well-known/acme-challenge/test.html
curl -L http://auxlink.duckdns.org/.well-known/acme-challenge/test.html
curl -L http://hass.auxlink.com/.well-known/acme-challenge/test.html

curl -L http://portainer.auxlink.com/.well-known/acme-challenge/test.html

#После проверки лучше удалить тестовый файл — certbot любит удалять за собой всё лишнее
sudo rm /var/www/letsencrypt/.well-known/acme-challenge/*

#удалить список архивных файлов cerbot
#sudo rm -rf /etc/letsencrypt/archive/*

#протестируем получение сертификатов, для боевого запуска нужно убрать --dry-run
#число боевых запусков ограничено 5 или 20 в неделю, всегда сначала пробуем в тестовом режиме
sudo certbot certonly --dry-run -d hub.auxlink.com -d portainer.auxlink.com -d hass.auxlink.com -d jira.auxlink.com

#Если нужно добавить поддомен или домен в сертификат
certbot certonly --expand --dry-run -d hub.auxlink.com -d wiki.auxlink.com -d demo.auxlink.com -d jira.auxlink.com -d git.auxlink.com -d mark.auxlink.com

certbot certonly --expand --dry-run -d hub.auxlink.com -d demo.auxlink.com -d hass.auxlink.com -d api.auxlink.com -d portainer.auxlink.com

#посмотрим файлы которые получились
find /etc/letsencrypt/live/ -type l

#проверим список сертификатов в домене
cat /etc/letsencrypt/live/*/cert.pem | openssl x509 -text | grep -o 'DNS:[^,]*' | cut -f2 -d:


##########################################################
#настройка автоматического обновления

#Если у вас не Debian или нет файла, то добавим в crontab от root одну лишь строчку (
#sudo crontab -e
#вставляем строчку ниже без #
#42 */12 * * * certbot renew --quiet --allow-subset-of-names
#или же сдклать как в 
#sudo nano /etc/cron.d/certbot
#только добавить ключ --allow-subset-of-names
0 */12 * * * root test -x /usr/bin/certbot -a \! -d /run/systemd/system && perl -e 'sleep int(rand(43200))' && certbot -q renew --allow-subset-of-names

##########################################################
#настройка конфигов сайтов NGINX

#скопируем настройки серверов
#можно начать с hub.conf это jupyterhub 
#сначала создаем файлы конфигурации в /etc/nginx/sites-avalable/
sudo cp ./sites-available/* /etc/nginx/sites-available/

# потом делаем линки на конфиги в папке sites-enabled
# без линка конфиг работать не будет
# линк позволяет избежать задваивания файлов
# лучше сайты запускать последовательно, чтобы проще было исправлять ошибки

sudo ln -s /etc/nginx/sites-available/hub.conf /etc/nginx/sites-enabled
#sudo ln -s /etc/nginx/sites-available/wiki.conf /etc/nginx/sites-enabled
#sudo ln -s /etc/nginx/sites-available/git.conf /etc/nginx/sites-enabled
#sudo ln -s /etc/nginx/sites-available/demo.conf /etc/nginx/sites-enabled
sudo ln -s /etc/nginx/sites-available/mark.conf /etc/nginx/sites-enabled
sudo ln -s /etc/nginx/sites-available/local.conf /etc/nginx/sites-enabled
sudo ln -s /etc/nginx/sites-available/auxlink.duckdns.org.conf /etc/nginx/sites-enabled
sudo ln -s /etc/nginx/sites-available/portainer.conf /etc/nginx/sites-enabled


#тест конфигурации без перезагрузки сервера
sudo nginx -t 

# Restart nginx because we changed the config files.
sudo service nginx restart