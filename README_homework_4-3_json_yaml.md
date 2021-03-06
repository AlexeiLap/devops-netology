# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
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

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
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

### Вывод скрипта при запуске при тестировании:

![Скриншот](img/4-3/сообщения%20при%20обнаружении%20ошибок.png)


### json-файл(ы), который(е) записал ваш скрипт:
```json
{"drive.google.com": ["64.233.163.194"], "mail.google.com": ["142.251.1.17", "142.251.1.83", "142.251.1.18", "142.251.1.19"], "google.com": ["173.194.222.100", "173.194.222.138", "173.194.222.113", "173.194.222.139", "173.194.222.101", "173.194.222.102"]}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
drive.google.com:
- 64.233.163.194
google.com:
- 173.194.222.100
- 173.194.222.138
- 173.194.222.113
- 173.194.222.139
- 173.194.222.101
- 173.194.222.102
mail.google.com:
- 142.251.1.17
- 142.251.1.83
- 142.251.1.18
- 142.251.1.19
```