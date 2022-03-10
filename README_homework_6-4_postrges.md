# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
Подключитесь к БД PostgreSQL используя `psql`.

```commandline
docker run -v C:/tmp/pg_hostdata:/pg_hostdata --name pg-13.3 -p 5432:5432 -e POSTGRES_PASSWORD=pgpwd4habr -d postgres:13.3
docker ps - проверить что работает
psql -U postgres - подключиться из консоли
\conninfo - информация о соединении
```

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
```commandline
- вывода списка БД
\l
- подключения к БД
psql -U postgres - заходим как пользователь
\connect test_database - покдлючаемся к базе данных
- вывода списка таблиц
\d - таблица
test_database=# \d
              List of relations
 Schema |     Name      |   Type   |  Owner
--------+---------------+----------+----------
 public | orders        | table    | postgres
 public | orders_id_seq | sequence | postgres
(2 rows)

\dS - системные таблицы
\da = 
- вывода описания содержимого таблиц
\d orders
test_database=# \d orders
                                   Table "public.orders"
 Column |         Type          | Collation | Nullable |              Default
--------+-----------------------+-----------+----------+------------------------------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass)
 title  | character varying(80) |           | not null |
 price  | integer               |           |          | 0
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
- выхода из psql
\q
```

## Задача 2

Используя `psql` создайте БД `test_database`.

`createdb -U postgres -W test_database`

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

`psql -U postgres -W test_database < /pg_hostdata/test_dump.sql`

Перейдите в управляющую консоль `psql` внутри контейнера.

`psql -U postgres`

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

`\connect test_database`
`ANALYZE orders`

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.
**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```commandline
test_database=# select attname,avg_width from pg_stats where tablename='orders' order by avg_width desc limit 1;
 attname | avg_width
---------+-----------
 title   |        16
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.
```commandline
create table orders_1 (check (price>499)) inherits (orders);
create table orders_2 (check (price<=499)) inherits (orders);

INSERT INTO orders_1 SELECT * FROM orders WHERE price>499;
INSERT INTO orders_2 SELECT * FROM orders WHERE price<=499;

DELETE FROM only orders WHERE price>499 or price<=499;

создаем правило
create rule new_orders_1 as on insert to orders where (price>499) do instead insert into orders_1 values (new.*);
create rule new_orders_2 as on insert to orders where (price<499) do instead insert into orders_2 values (new.*);

```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?


```commandline
CREATE TABLE orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
)
create table orders_1 (check (price>499)) inherits (orders);
create table orders_2 (check (price<=499)) inherits (orders);
create rule new_orders_1 as on insert to orders where (price>499) do instead insert into orders_1 values (new.*);
create rule new_orders_2 as on insert to orders where (price<499) do instead insert into orders_2 values (new.*);

```

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

`pg_dump -U postgres -W test_database > /pg_hostdata/test_dump.dump`

Доработка
```commandline
CREATE unique INDEX title_un ON public.orders (title);
либо описание самой таблицы
CREATE TABLE public.orders_new2 (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0, 
	UNIQUE (title)
);
```
---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
