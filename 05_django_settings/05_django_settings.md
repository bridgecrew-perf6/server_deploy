# 1. тестирование настройка конфигурации setup.cfg

# 2. .gitignore
проверяем что static files попадают на github

# 3. django project settings.py

STATIC_URL = '/static/'
#STATICFILES_DIRS = [os.path.join(BASE_DIR, 'static')]
STATIC_ROOT = os.path.join(BASE_DIR, 'static/')

LOGIN_URL = 'users:login'
LOGIN_REDIRECT_URL = 'posts:index'
/ # LOGOUT_REDIRECT_URL = 'posts:index'

EMAIL_BACKEND = 'django.core.mail.backends.filebased.EmailBackend'
EMAIL_FILE_PATH = os.path.join(BASE_DIR, 'sent_emails/')

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media/')

## 3. Django url.py

from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path, re_path
from django.views.static import serve

urlpatterns = [
    path('admin/', admin.site.urls),
    path('auth/', include('users.urls', namespace='users')),
    path('auth/', include('django.contrib.auth.urls')),
    path('about/', include('about.urls', namespace='about')),
    path('', include('posts.urls', namespace='posts')),
]
### static files must have ###
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
urlpatterns += [re_path(r'^media/(?P<path>.*)$', serve, {'document_root': settings.MEDIA_ROOT,}),]
###

handler404 = 'core.views.page_not_found'
handler500 = 'core.views.server_error'
handler403 = 'core.views.permission_denied'
if settings.DEBUG:
    import debug_toolbar

    urlpatterns += static(
        settings.MEDIA_URL, document_root=settings.MEDIA_ROOT
    )
    urlpatterns += (path('__debug__/', include(debug_toolbar.urls)),)


4. доступы к файлам и папкам

надо чтобы весь путь до файлов был доступен на исполнение (это позволяет делать поиск в директории)

как проверить: начинаем с домашней папки пользователя (куда ставили проект, и из под кого запускаем gunicorn)

ввод di@mini:~/hw05_final$ stat -c "%a" /home/di
вывод 750 - вот здесь проблема
di@mini:~/hw05_final$ stat -c "%a" /home/di/hw05_final/
775
di@mini:~/hw05_final$ stat -c "%a" /home/di/hw05_final/yatube
775
di@mini:~/hw05_final$ stat -c "%a" /home/di/hw05_final/yatube/static
775
di@mini:~/hw05_final$ 

#открываем доступ, решение только учебное, тк становится видна для чтения домашняя папка пользователя
sudo chmod 755 /home/di

#проверяем что к статическому файлу есть доступ
sudo -u www-data ls /home/di/hw05_final/yatube/static/css/


5. Nginx
проверить от какого пользователя запускается nginx

### nginx.conf ###
### Располагается в /etc/nginx/
    # Пользователь сервера
    user                       www-data;

не рекомендуется запускать nginx от имени пользователя под которым создана домашняя директория, тк в случае взлома утекут все данные всех пользователей :)

6. Nginx пути к статическим файлам

    location /static/ {
         root /home/di/hw05_final/yatube/;
     }

     # медиа файлы
     location /media/ {
         root /home/di/hw05_final/yatube/;
     }

    location / {
        include proxy_params;
        proxy_pass http://127.0.0.1:8000;
    }



7. статусы работы и логи
убедиться что все работает.
sudo systemctl status nginx 
sudo systemctl status gunicorn.service

логи, можно прописать конфигурации nginx, и потом смотреть


server {

    
    access_log /var/log/nginx/site_access.log;
    error_log /var/log/nginx/site_error.log;

} 

