# Домашнее задание к занятию "6.3. MySQL"

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
```commandline
select version();
mysql> select version();
+-----------+
| version() |
+-----------+
| 8.0.28    |
+-----------+
1 row in set (0.00 sec)
```


Подключитесь к восстановленной БД и получите список таблиц из этой БД.
```commandline
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test_db            |
+--------------------+
5 rows in set (0.00 sec)
USE test_db
mysql> SHOW TABLES;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```


**Приведите в ответе** количество записей с `price` > 300.
```commandline
mysql> select count(*) from orders where price >300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

В следующих заданиях мы будем продолжать работу с данным контейнером.

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

```commandline
CREATE USER 'test'@'localhost'
IDENTIFIED WITH mysql_native_password BY 'test-pass'
WITH MAX_QUERIES_PER_HOUR 100 
PASSWORD EXPIRE INTERVAL 180 DAY
FAILED_LOGIN_ATTEMPTS 3
ATTRIBUTE '{"Family": "Pretty", "Name": "James"}';

SELECT User, Host FROM mysql.user;

SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER = 'test' AND HOST = 'localhost'\G

```

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
```commandline
GRANT SELECT ON `test_db`.* TO 'test'@'localhost';
FLUSH PRIVILEGES;
```

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.
```commandline
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER = 'test' AND HOST = 'localhost'\G
*************************** 1. row ***************************
     USER: test
     HOST: localhost
ATTRIBUTE: {"Name": "James", "Family": "Pretty"}
1 row in set (0.00 sec)

```


## Задача 3

Установите профилирование `SET profiling = 1`.
`set profiling=1;`
Изучите вывод профилирования команд `SHOW PROFILES;`.
```commandline
SHOW PROFILES;
 show profiles;
+----------+------------+-----------------------------+
| Query_ID | Duration   | Query                       |
+----------+------------+-----------------------------+
|        1 | 0.00105975 | select count(1) from orders |
|        2 | 0.00087050 | select count(1) from orders |
+----------+------------+-----------------------------+
2 rows in set, 1 warning (0.00 sec)

show profile for query 1;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000129 |
| Executing hook on transaction  | 0.000005 |
| starting                       | 0.000027 |
| checking permissions           | 0.000008 |
| Opening tables                 | 0.000031 |
| init                           | 0.000005 |
| System lock                    | 0.000007 |
| optimizing                     | 0.000005 |
| statistics                     | 0.000016 |
| preparing                      | 0.000033 |
| executing                      | 0.000708 |
| end                            | 0.000013 |
| query end                      | 0.000004 |
| waiting for handler commit     | 0.000009 |
| closing tables                 | 0.000009 |
| freeing items                  | 0.000044 |
| cleaning up                    | 0.000011 |
+--------------------------------+----------+
17 rows in set, 1 warning (0.00 sec)
```


Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**. InnoDB
```commandline
mysql> SHOW CREATE TABLE orders\G;
*************************** 1. row ***************************
       Table: orders
Create Table: CREATE TABLE `orders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(80) NOT NULL,
  `price` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
1 row in set (0.00 sec)
```


Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

```commandline
ALTER TABLE orders ENGINE = MyISAM;
ALTER TABLE orders ENGINE = InnoDB;
SHOW PROFILES;
|        7 | 0.04811225 | ALTER TABLE orders ENGINE = MyISAM |
|        8 | 0.03831350 | ALTER TABLE orders ENGINE = InnoDB |
```


## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
innodb_flush_log_at_trx_commit = 2​ - для случаев, когда небольшая потеря данных не критична. 
innodb_flush_log_at_trx_commit = 0 - самый производительный, но небезопасный вариант.
- Нужна компрессия таблиц для экономии места на диске
innodb_file_per_table=1
- Размер буффера с незакомиченными транзакциями 1 Мб
read_buffer_size = 1M 
- Буффер кеширования 30% от ОЗУ
query_cache_size = 3845M
- Размер файла логов операций 100 Мб
innodb_log_file_size = 100М

Приведите в ответе измененный файл `my.cnf`.
```commandline
[mysqld]
# опции которые были
skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
secure-file-priv=/var/lib/mysql-files
user=mysql
pid-file=/var/run/mysqld/mysqld.pid

# новые опции
innodb_flush_log_at_trx_commit = 2​
innodb_file_per_table=1
innodb_log_file_size = 100М
read_buffer_size = 1M 
query_cache_size = 3845M
```
### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
