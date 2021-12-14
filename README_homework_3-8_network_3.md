# Домашнее задание к занятию "3.8. Компьютерные сети, лекция 3"

1. Подключитесь к публичному маршрутизатору в интернет. Найдите маршрут к вашему публичному IP

```
telnet route-views.routeviews.org
Username: rviews
show ip route *.*.*.*/32
show ip route 89.109.44.119/32
show ip 89.109.44.119 
show bgp 89.109.44.119/32
```

ОТВЕТ: `wget -qO- eth0.me - узнать свой внешний ip адрес`
```
show ip route 89.109.44.119
Routing entry for 89.109.44.0/24
  Known via "bgp 6447", distance 20, metric 0
  Tag 701, type external
  Last update from 137.39.3.55 4d01h ago
  Routing Descriptor Blocks:
  * 137.39.3.55, from 137.39.3.55, 4d01h ago
      Route metric is 0, traffic share count is 1
      AS Hops 3
      Route tag 701
      MPLS label: none
	  
show bgp 89.109.44.119
BGP routing table entry for 89.109.44.0/24, version 1407284488
Paths: (3 available, best #3, table default)
  Not advertised to any peer
  Refresh Epoch 1
  20912 49367 6762 12389
    212.66.96.126 from 212.66.96.126 (212.66.96.126)
      Origin IGP, localpref 100, valid, external
      Community: 6762:1 6762:30 6762:40 6762:14900 20912:65005 49367:2 49367:6762
      path 7FE041A55298 RPKI State invalid
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  49788 12552 12389
    91.218.184.60 from 91.218.184.60 (91.218.184.60)
      Origin IGP, localpref 100, valid, external
      Community: 12552:12000 12552:12100 12552:12101 12552:22000
      Extended Community: 0x43:100:1
      path 7FE0B77DEF48 RPKI State invalid
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  701 1273 12389
    137.39.3.55 from 137.39.3.55 (137.39.3.55)
      Origin IGP, localpref 100, valid, external, best
      path 7FE0295AD630 RPKI State invalid
      rx pathid: 0, tx pathid: 0x0
```

 - до /32 не находит
 - show bgp 89.109.44.119/32
 - % Network not in table
 
 show ip route 89.109.44.119 longer-prefixes

2. Создайте dummy0 интерфейс в Ubuntu. 
Добавьте несколько статических маршрутов. 
Проверьте таблицу маршрутизации.

ОТВЕТ:
загрузить модуль «dummy», можно также добавить опцию «numdummies=2» чтобы сразу создалось два интерфейса dummyX:
`sudo modprobe -v dummy numdummies=2`
- Посмотрим загрузился ли модуль:
- lsmod | grep dummy
- Посмотрим создались ли интерфейсы:
- ifconfig -a | grep dummy

добавление маршрутров
```
sudo ip route add 243.143.5.25 via 10.0.0.1
sudo ip route add 243.143.5.26 via 10.0.0.1
sudo ip route add 243.143.5.27 via 10.0.0.1
```

посмотреть таблицу `ip route`
![Скриншот](img/3-8/создались%20dummy%20интерфейсы.png)
![Скриншот](img/3-8/модули%20dummy%20проверка%20что%20создались.png)
![Скриншот](img/3-8/добавленные%20маршруты%20через%20dummy2.png)

3. Проверьте открытые TCP порты в Ubuntu, 
какие протоколы и приложения используют эти порты? 
Приведите несколько примеров.
```
netstat -pnltu - проверить порты
netstat -ntlp | grep LISTEN
sudo lsof -nP -i | grep LISTEN - показывает какие программы используют порты
программы и используемые порты
prometheu  623      prometheus    3u  IPv6  22920      0t0  TCP *:9100 (LISTEN)
netdata    724         netdata    4u  IPv4  24799      0t0  TCP 127.0.0.1:19999 (LISTEN)
netdata    724         netdata   45u  IPv6  26059      0t0  TCP [::1]:8125 (LISTEN)
```

4. Проверьте используемые UDP сокеты в Ubuntu, 
какие протоколы и приложения используют эти порты?
```
ss -ua  UDP сокеты 
ss -p Показать процесс использующий сокет
```
![Скриншот](img/3-8/процессы%20использующие%20сокеты.png)


5. Используя diagrams.net, создайте L3 диаграмму вашей домашней сети или любой другой сети, 
с которой вы работали. 
![Скриншот](img/3-8/диаграмма%20домашней%20сети.png)

 ---