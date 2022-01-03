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

`sites.txt - файл сайтов для проверки, исходное содержимое`
```
drive.google.com has address 74.125.131.194
mail.google.com has address 142.251.1.17
google.com has address 173.194.222.101
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import time
while 1==1:
        print('НОВАЯ ПРОВЕРКА')
        time.sleep(5)
        f = open('sites.txt', 'r')
        lines = [line.strip() for line in f]
        f.close()
        #создаем список проверенных сайтов
        checked_sites=[]
        f = open('sites.txt', 'w')
        for line in lines:
                #print('проверяем строчку в файле: ' + line)
                site = line.split(' has address ')
                #сохранили старый ip
                old_ip=site[1]
                #если сайт уже в проверенных то сразу проверяем  на наличие ip
                if site[0] in checked_sites:
                        if old_ip not in new_ips:
                                print('[ERROR] ' + site[0] + ' IP mismatch: ' + old_ip + ' Новые ip: ' + ' && '.join(new_ips))
                #если сайт не проверяли то шлем запрос
                else:
                        checked_sites.append(site[0])
                        result_os = os.popen("host " + site[0]).read()
                        #print('- запустили команду: ' + "host " + site[0])
                        #формируем список новых ip
                        new_ips=[]
                        for result in result_os.split('\n'):
                                if result.find(' has address ') != -1:
                                        new_data=result.split(' has address ')
                                        new_ips.append(new_data[1])
                                        #print('-- нашли адрес для сайта: ' + site[0] + ' ' + new_data[1])
                                        #записываем данные в файл
                                        f.write(site[0] + ' has address ' + new_data[1] + '\n')
                                        #print('-- ip сайта ' + site[0] + ' - ' + new_data[1])
                        #если в новых адресах нет старого ip то выдаем сообщение что ip изменен
						if old_ip not in new_ips:
                                print('[ERROR] ' + site[0] + ' IP mismatch: ' + old_ip + ' Новые ip: ' + ' && '.join(new_ips))
        f.close()
```

### Вывод скрипта при запуске при тестировании:

![Скриншот](img/4-2/результаты%20проверки%20ip%20адресов.png)
