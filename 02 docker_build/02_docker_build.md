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