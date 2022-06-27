На докер файл влияет actions.yml блок  context: ./api_yamdb/ определяет рабочую директорию

        - name: Push to Docker Hub
          uses: docker/build-push-action@v2 
          with:
            context: ./api_yamdb/
            push: true
            tags: ${{ secrets.DOCKER_USERNAME }}/yamdb_final:latest

пример Dockerfile

FROM python:3.9
WORKDIR /app
COPY . .
RUN pip3 install -r requirements.txt --no-cache-dir
CMD ["gunicorn", "api_yamdb.wsgi:application", "--bind", "0:8000" ]


?? вопрос ??  нужно ли CMD по старту контейнера переносить в compose

Если вы вдруг решили собрать статику и сделали build докерфайла и опять в контейнере нет redoc.yaml
Это значит что у вас build собирает определённые слои из Кеша (в том числе и volumes) для этого, перед основательной пересборкой образа, нужно очистить весь кеш командой

builder prune

Важно не обновлять докерфайл а отправлять новую версию в докерхаб (то есть репозиторий должен быть очищен или создан новый тег)

Ваш образ должен быть записан тегом не latest, а v1, v2 каким-либо другим, отличным от latest)