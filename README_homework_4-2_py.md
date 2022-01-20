# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | будет ошибка: TypeError: unsupported operand type(s) for +: 'int' and 'str'  |
| Как получить для переменной `c` значение 12?  | сделать преобразование: c = str(a) + b  |
| Как получить для переменной `c` значение 3?  | сделать преобразование: c = int(a) + int(b)  |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        print("/netology/sysadm-homeworks/" + result.replace('\tmodified:   ', ''))
```

### Вывод скрипта при запуске при тестировании:
```commandline
vagrant@vagrant:~$ python3 pt0.py
/netology/sysadm-homeworks/file1.txt
/netology/sysadm-homeworks/file3.txt
/netology/sysadm-homeworks/first_homework/new.txt
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import sys
path=sys.argv[1]
bash_command = ["cd ~" + path, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
  if result.find('modified') != -1:
     print(path + ' ' + result.replace('\tmodified:   ', ''))
```

### Вывод скрипта при запуске при тестировании:
```
vagrant@vagrant:~$ python3 pt1.py /netology/sysadm-homeworks
/netology/sysadm-homeworks file1.txt
/netology/sysadm-homeworks file3.txt
/netology/sysadm-homeworks first_homework/new.txt
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

Доработанный вариант через файл json и словарь

### Ваш скрипт:
```python
#!/usr/bin/env python3
import os
import time
import json
import socket

while True:
    print('НОВАЯ ПРОВЕРКА')
    #вводим признак изменений
    wasChanged=0
    time.sleep(1)
    #читаем данные из словаря
    with open('sites.json') as json_file:
        json_dict = json.load(json_file)
    for site in json_dict:
        print('проверяем host: ' + site)
        host = socket.gethostbyname(site)
        if host != json_dict[site]:
            wasChanged=1
            print('[ERROR] ' + site + ' IP mismatch ' + ' old_ip ' + json_dict[site] + ' Новый IP ' + host)
        #перезаписываем словарь
        json_dict[site]=host
    #если при проверке были изменения то перезаписываем файл json
    if wasChanged==1:
        with open('sites.json', 'w') as outfile:
            json.dump(json_dict, outfile)
```

### Вывод скрипта при запуске при тестировании:

![Скриншот](img/4-2/сообщения%20новые.png)

Содержимое файла json новое

![Скриншот](img/4-2/содержимое%20файла%20json%20новое.png)
