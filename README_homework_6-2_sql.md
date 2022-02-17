# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.
Приведите получившуюся команду или docker-compose манифест.
```
docker volume create pg-backup - создаем том для базы
docker run -v pg-backup:/pg-backup --name pg-12.10 -p 5432:5432 -e POSTGRES_PASSWORD=pgpwd4habr -d postgres:12.10 - запускаем контейнер
```

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
`create database test_db;`
`create user "test-admin-user";`
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
```sql
SELECT * FROM information_schema.columns
WHERE table_schema = 'public'
   AND table_name   = 'clients'
SELECT * FROM information_schema.columns
WHERE table_schema = 'public'
   AND table_name   = 'orders'
```
![Описание таблиц](img/6-2/описание%20таблицы%20clients.png)
![Описание таблиц](img/6-2/описание%20таблицы%20orders.png)

- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
```commandline
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "test-admin-user";
SELECT * FROM information_schema.table_privileges where (table_name='orders' or table_name='clients') and grantee='test-admin-user';
```
![Описание таблиц](img/6-2/права%20пользователя%20test-admin.png)
- создайте пользователя test-simple-user
`create user "test-simple-user";`
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
`GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA public TO "test-simple-user";`

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,

- описание таблиц (describe)
```commandline
test_db=# \d clients
                         Table "public.clients"
      Column       |       Type        | Collation | Nullable | Default
-------------------+-------------------+-----------+----------+---------
 id                | integer           |           | not null |
 фамилия           | character varying |           |          |
 страна проживания | character varying |           |          |
 заказ             | integer           |           |          |
Indexes:
    "clients_pk" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients__orders" FOREIGN KEY ("заказ") REFERENCES orders(id)
	
test_db=# \d orders
                       Table "public.orders"
    Column    |       Type        | Collation | Nullable | Default
--------------+-------------------+-----------+----------+---------
 id           | integer           |           | not null |
 наименование | character varying |           |          |
 цена         | integer           |           |          |
Indexes:
    "orders_pk" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients__orders" FOREIGN KEY ("заказ") REFERENCES orders(id)
```
	
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
`SELECT * FROM information_schema.table_privileges where (table_name='orders' or table_name='clients')`

- список пользователей с правами над таблицами test_db
![Описание таблиц](img/6-2/список%20пользователей%20с%20правами%20над%20таблицам.png)
## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.
```commandline
insert into clients (id, фамилия, "страна проживания") VALUES (1,'Иванов Иван Иванович', 'USA');
insert into clients (id, фамилия, "страна проживания") VALUES (2,'Петров Петр Петрович', 'Canada');
insert into clients (id, фамилия, "страна проживания") VALUES (3,'Иоганн Себастьян Бах', 'Japan');
insert into clients (id, фамилия, "страна проживания") VALUES (4,'Ронни Джеймс Дио', 'Russia');
insert into clients (id, фамилия, "страна проживания") VALUES (5,'Ritchie Blackmore', 'Russia');
insert into orders (id, наименование, цена) VALUES (1,'Шоколад', 10);
insert into orders (id, наименование, цена) VALUES (2,'Принтер', 3000);
insert into orders (id, наименование, цена) VALUES (3,'Книга', 500);
insert into orders (id, наименование, цена) VALUES (4,'Монитор', 7000);
insert into orders (id, наименование, цена) VALUES (5,'Гитара', 4000);

select count(*) from orders;
select count(*) from clients;
```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.
```commandline
update clients set заказ=(select id from orders where наименование='Книга') where фамилия='Иванов Иван Иванович';
update clients set заказ=(select id from orders where наименование='Монитор') where фамилия='Петров Петр Петрович';
update clients set заказ=(select id from orders where наименование='Гитара') where фамилия='Иоганн Себастьян Бах';
```


Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 `select * from clients where заказ is not null;` 
![Пользователи совершившие заказ](img/6-2/пользователи%20совершившие%20заказ.png)

Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.
`EXPLAIN select * from clients where заказ is not null;`
![EXPLAIN запроса](img/6-2/explain%20запроса.png)
В нашем случае EXPLAIN сообщает, что используется Seq Scan — последовательное, блок за блоком.
Что такое cost? Это не время, а некое сферическое в вакууме понятие, призванное оценить затратность операции. 
Первое значение 0.00 — затраты на получение первой строки. 
Второе — затраты на получение всех строк.
rows — приблизительное количество возвращаемых строк при выполнении операции Seq Scan. 
Это значение возвращает планировщик. width — средний размер одной строки в байтах.
## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
`pg_dump -U postgres -W test_db > /pg-backup/test_db.dump`
Остановите контейнер с PostgreSQL (но не удаляйте volumes).
`docker stop 2f19e2121227`
Поднимите новый пустой контейнер с PostgreSQL.
`docker run -v pg-backup:/pg-backup --name pg-12.10-new -p 5432:5432 -e POSTGRES_PASSWORD=pgpwd4habr -d postgres:12.10 - запускаем контейнер`
Восстановите БД test_db в новом контейнере.
Приведите список операций, который вы применяли для бэкапа данных и восстановления.
`createdb -U postgres -W test_db`
`psql -U postgres -W test_db < /pg-backup/test_db.dump`
---