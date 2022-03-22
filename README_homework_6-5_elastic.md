# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Ответ
- текст Dockerfile манифеста
```
FROM centos
LABEL maintainer="alexeilapshov@yandex.ru"
# Устраняем ошибку без которой дальнейшие команды не будут работать
RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN cd /
# Обновляем устанавливаем нужные программы
RUN yum update -y
RUN yum install -y wget
RUN yum install -y perl-Digest-SHA
RUN yum install -y java
RUN yum install -y sudo
# Скачиваем архив и проверяем контрольные суммыы
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.0-linux-x86_64.tar.gz
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.0-linux-x86_64.tar.gz.sha512
RUN shasum -a 512 -c elasticsearch-8.1.0-linux-x86_64.tar.gz.sha512
RUN tar -xzf elasticsearch-8.1.0-linux-x86_64.tar.gz
# Копируем файл конфигурации и запускаем приложение
COPY elasticsearch.yml /elasticsearch-8.1.0/config
# Создаем директорию для хранения данных
RUN mkdir /var/lib/elasticsearch
# Создаем нового пользователя для запуска
RUN groupadd elasticsearch
RUN useradd elasticsearch -g elasticsearch -p elasticsearch
RUN chown -R elasticsearch:elasticsearch /elasticsearch-8.1.0
RUN chown -R elasticsearch:elasticsearch /var/lib/elasticsearch
# Запускаем приложение
CMD sudo -u elasticsearch ./elasticsearch-8.1.0/bin/elasticsearch
# Открываем порты
EXPOSE 9200
EXPOSE 9300
```
- ссылку на образ в репозитории dockerhub

https://hub.docker.com/repository/docker/alexeilapshov/centos_elastic_21-03

- ответ `elasticsearch` на запрос пути `/` в json виде
```
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "z8JSnUY0RUCRGNGEaO223g",
  "version" : {
    "number" : "8.1.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "3700f7679f7d95e36da0b43762189bab189bc53a",
    "build_date" : "2022-03-03T14:20:00.690422633Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```
Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

`curl -X GET "http://localhost:9200/_cat/indices?pretty"`
```
green  open ind-1 sISBfuinQIqnId0iY1mIdA 1 0 0 0 225b 225b
yellow open ind-3 no8OY17JR2yXIwXevNgEhA 4 2 0 0 900b 900b
yellow open ind-2 kn8hQ07cQ3ybMg6wWDyknw 2 1 0 0 450b 450b
```
Получите состояние кластера `elasticsearch`, используя API.

`curl -X GET "localhost:9200/_cluster/health?pretty"`
```
{
    "cluster_name": "elasticsearch",
    "status": "yellow",
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 8,
    "active_shards": 8,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 10,
    "delayed_unassigned_shards": 0,
    "number_of_pending_tasks": 0,
    "number_of_in_flight_fetch": 0,
    "task_max_waiting_in_queue_millis": 0,
    "active_shards_percent_as_number": 44.44444444444444
}
```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
```
Потому что ElasticSearch является отказоустойчивой системой хранения данных, которая расчитана для запуска не на одном сервере, а на группе (кластере) из нескольких связанных серверов (узлов, “nodes”).
В частности, ElasticSearch подразумевает, что при отказе одного узла система должна сохранять полную работоспособность.
Для этого система должна состоять из нескольких серверов (минимум — двух, желательно — трёх для предотвращения split brain), и каждая порция данных (т.н. “shard” в терминологии ES) должна храниться в нескольких экземплярах на разных серверах.
Один из этих экземпляров ES будет считать первичным (“master shard”), остальные копиями первичного (“replica shards”).
В системе из одного сервера ES хранит на нём все “primary shards”, но создавать “replica shards” такой системе будет негде.
Поэтому статус в приведённом примере является жёлтым из-за ненулевого значения “unassigned_shards”, которое примерно равно “active_shards”.
Небольшая разница между количеством активных и неразмещённых шардов обусловлена тем, что часть служебных индексов является локальной для каждого узла, то есть не должна иметь реплик и не приводит к появлению unassigned shards.
```

Удалите все индексы.
```commandline
curl -X DELETE "localhost:9200/ind-1?pretty"
curl -X DELETE "localhost:9200/ind-2?pretty"
curl -X DELETE "localhost:9200/ind-3?pretty"
```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

`mkdir /elasticsearch-8.1.0/snapshots`

`chown  -R elasticsearch:elasticsearch  /elasticsearch-8.1.0/snapshots`


Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.
```commandline
curl --location --request PUT 'localhost:9200/_snapshot/netology_backup?pretty' \
--header 'Content-Type: application/json' \
--data-raw '{
  "type": "fs",
  "settings": {
    "location": "snapshots"
  }
}'
Ответ
{
    "acknowledged": true
}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.
```commandline
curl --location --request PUT 'localhost:9200/test?pretty' \
--header 'Content-Type: application/json' \
--data-raw '{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}'
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

`curl -X PUT "localhost:9200/_snapshot/netology_backup/my_snapshot?wait_for_completion=true&pretty"`

```
{
    "snapshot": {
        "snapshot": "my_snapshot",
        "uuid": "W4x9r1biQ0iX9WOXPF0zdQ",
        "repository": "netology_backup",
        "version_id": 8010099,
        "version": "8.1.0",
        "indices": [
            ".geoip_databases",
            "test"
        ],
        "data_streams": [],
        "include_global_state": true,
        "state": "SUCCESS",
        "start_time": "2022-03-21T08:03:20.459Z",
        "start_time_in_millis": 1647849800459,
        "end_time": "2022-03-21T08:03:52.113Z",
        "end_time_in_millis": 1647849832113,
        "duration_in_millis": 31654,
        "failures": [],
        "shards": {
            "total": 2,
            "failed": 0,
            "successful": 2
        },
        "feature_states": [
            {
                "feature_name": "geoip",
                "indices": [
                    ".geoip_databases"
                ]
            }
        ]
    }
}
```

**Приведите в ответе** список файлов в директории со `snapshot`ами.

```
sh-4.4# ls
index-0  index.latest  indices  meta-W4x9r1biQ0iX9WOXPF0zdQ.dat  snap-W4x9r1biQ0iX9WOXPF0zdQ.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.
```commandline
curl -X DELETE "localhost:9200/test?pretty"

curl --location --request PUT 'localhost:9200/test3?pretty' \
--header 'Content-Type: application/json' \
--data-raw '{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}'
```
Список индексов:

`curl --location --request GET 'http://localhost:9200/_cat/indices?pretty'`
```
green open test3 KhhuBa9ORBWQZO9UgARk1A 1 0 0 0 225b 225b
```
[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.
```commandline
curl -X POST "localhost:9200/_snapshot/netology_backup/my_snapshot/_restore?pretty"
curl --location --request GET 'http://localhost:9200/_cat/indices?pretty'
```
```
green open test3 KhhuBa9ORBWQZO9UgARk1A 1 0 0 0 225b 225b
green open test  MYBC-iw4QE2Q7vVXLX3RFA 1 0 0 0 225b 225b
```

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---