# Домашнее задание к занятию "3.5. Файловые системы"

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) 
(разряженных) файлах.

ОТВЕТ: ознакомился

2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

ОТВЕТ: не могут, поскольку жесткие ссылки это всегда один и тот же файл с одинаковыми правами доступа и владельцем.
При изменении прав доступа и владельца у одной жесткой ссылки права доступа и владелец изменится у всех остальных.

3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

ОТВЕТ: выполнено

4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

ОТВЕТ: выполнено
команда: `sudo fdisk /dev/sdb` - передаем блочное устройство (n -новый, w-записать изменения)
![Скриншот](img/3-5/разбитый%20первый%20на%202%20и%200-5.png)

5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.

ОТВЕТ: выполнено
команда: 
```bash
sudo sfdisk -d /dev/sdb > sdb-tables.txt - сохраняем таблицу
sudo sfdisk /dev/sdc < sdb-tables.txt - переносим на диск sdс
```
![Скриншот](img/3-5/разбитый%20второй%20как%20и%20первый%20на%202%20и%200-5.png)

6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

ОТВЕТ: создан md1,
команды: 
```bash
sudo mdadm --zero-superblock --force /dev/sd{b,c}1  - занулить суперблоки
sudo wipefs --all --force /dev/sd{b,c}1 удалить старые метаданные и подпись на дисках
sudo mdadm --create --verbose /dev/md1 -l 1 -n 2 /dev/sd{b,c}1 - собираем рейд1
```
![Скриншот](img/3-5/созданные%20рейды.png)

7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

ОТВЕТ: создан md0,команды: 
```bash
sudo mdadm --zero-superblock --force /dev/sd{b,c}2
sudo wipefs --all --force /dev/sd{b,c}2
sudo mdadm --create --verbose /dev/md0 -l 0 -n 2 /dev/sd{b,c}2
```
![Скриншот](img/3-5/созданные%20рейды.png)

8. Создайте 2 независимых PV на получившихся md-устройствах.

ОТВЕТ: создано 2 pv, команды:
```bash
sudo pvcreate /dev/md0 - создаем pv
sudo pvcreate /dev/md1 - создаем pv
sudo pvscan - просмотр созданных pv
```
![Скриншот](img/3-5/2-созданных%20lvm.png)

9. Создайте общую volume-group на этих двух PV.

ОТВЕТ: создана группа в нее включены pv
```bash
sudo vgcreate vol_grp1 /dev/md0 /dev/md1 - создаем группу
sudo vgdisplay - просмотр списка групп
```
![Скриншот](img/3-5/созданная%20группа.png)
![Скриншот](img/3-5/включены%20в%20группу%20общую.png)
10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.
ОТВЕТ: выполнено
```bash
sudo lvcreate -L 100M -n logical_vol1 vol_grp1 /dev/md0 - создание логического раздела
```
![Скриншот](img/3-5/созданный%20раздел.png)

11. Создайте `mkfs.ext4` ФС на получившемся LV.
ОТВЕТ: выполнено
```bash
sudo mkfs.ext4 /dev/vol_grp1/logical_vol1 - форматируем в файловую систему
```
12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.
ОТВЕТ: сделано в директорию mnt
```bash
sudo mount /dev/vol_grp1/logical_vol1 /mnt/ - монтируем в директорию
```
13. Поместите туда тестовый файл, например 
`wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /mnt/test.gz`.
ОТВЕТ: сделано
```bash
wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /mnt/test.gz
```

14. Прикрепите вывод `lsblk`.
ОТВЕТ: выполнено
![Скриншот](img/3-5/вывод%20команды%20lsblk.png)

15. Протестируйте целостность файла:

     ```bash
     root@vagrant:~# gzip -t /tmp/new/test.gz
     root@vagrant:~# echo $?
     0
     ```
     ОТВЕТ: сделано
![Скриншот](img/3-5/тестирование%20целостности.png)

16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.
ОТВЕТ: сделано
![Скриншот](img/3-5/перенос%20данных.png)

17. Сделайте `--fail` на устройство в вашем RAID1 md.

ОТВЕТ: сделано
`mdadm /dev/md1 --fail - делаем сбойным`

18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.
ОТВЕТ: сделано
![Скриншот](img/3-5/md1%20разрушенный%20неактивный.png)

19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

     ```bash
     root@vagrant:~# gzip -t /tmp/new/test.gz
     root@vagrant:~# echo $?
     0
     ```
ОТВЕТ: сделано
![Скриншот](img/3-5/повторный%20тест%20целостности%20файла.png)

20. Погасите тестовый хост, `vagrant destroy`.
ОТВЕТ: сделано 
 ---
