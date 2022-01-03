# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"

## Обязательные задания

1. Мы выгрузили JSON, который получили через API запрос к нашему сервису:
	```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
	```
  Нужно найти и исправить все ошибки, которые допускает наш сервис
  
ОТВЕТ: Исправленный
  ```
  { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
  ```
    

2. В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. 
К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. 
Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. 
Формат записи YAML по одному сервису: - имя сервиса: его IP. 
Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

ОТВЕТ: доработанный скрипт
--первоначальное наполнение файлов:

sites.txt
```
drive.google.com has address 64.233.163.194
mail.google.com has address 142.251.1.19
google.com has address 173.194.222.100
```

sites.yaml

```
'drive.google.com':
- 142.251.1.194
'mail.google.com': 
- 142.251.1.17
'google.com': 
- 64.233.161.101
```
sites.json
```
{
  {
    "drive.google.com": [
      "142.251.1.194"
    ]
  }, 
  {
    "mail.google.com": [
      "142.251.1.17"
    ]
  }, 
  {
    "google.com": [
      "64.233.161.101"
    ]
  }
}
```
СКРИПТ доработанный


```python
#!/usr/bin/env python3
import os
import time
import json
import yaml

while 1==1:
        print('НОВАЯ ПРОВЕРКА')
        #вводим признак изменений
        wasChanged=0
        time.sleep(5)
        f = open('sites.txt', 'r')
        lines = [line.strip() for line in f]
        f.close()
        #читаем yaml
        with open('sites.yaml') as fh:
                yaml_dict = yaml.safe_load(fh)
        #читаем json
        with open('sites.json') as json_file:
                json_dict = json.load(json_file)

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
                                yaml_dict[site[0]]=new_ips
                                json_dict[site[0]]=new_ips
                                wasChanged=1
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
                                yaml_dict[site[0]]=new_ips
                                json_dict[site[0]]=new_ips
                                wasChanged=1
        f.close()
		#если при проверке были изменения то перезаписываем файлы json и yaml
        if wasChanged==1:
                with open('sites.json', 'w') as outfile:
                        json.dump(json_dict, outfile)
                with open('sites.yaml', 'w') as f:
                        yaml.dump(yaml_dict, f)
```
Сообщение при обнаружении нового ip

![Скриншот](img/4-3/сообщения%20при%20обнаружении%20ошибок.png)

Формируемые файлы json и yaml

![Скриншот](img/4-3/структура%20формируемых%20файлов.png)

---
