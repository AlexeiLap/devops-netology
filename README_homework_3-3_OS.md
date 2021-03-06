# Домашнее задание к занятию "3.3. Операционные системы, лекция 1"

1. Какой системный вызов делает команда `cd`? 
В прошлом ДЗ мы выяснили, что `cd` не является самостоятельной  программой, это `shell builtin`, 
поэтому запустить `strace` непосредственно на `cd` не получится. 
Тем не менее, вы можете запустить `strace` на `/bin/bash -c 'cd /tmp'`. 
В этом случае вы увидите полный список системных вызовов, которые делает сам `bash` при старте. 
Вам нужно найти тот единственный, который относится именно к `cd`.
- ОТВЕТ: ищем командой `strace -e trace=chdir /bin/bash -c 'cd /tmp'`
- получаем результат: `chdir("/tmp")`

2. Попробуйте использовать команду `file` на объекты разных типов на файловой системе. Например:
    ```bash
    vagrant@netology1:~$ file /dev/tty
    /dev/tty: character special (5/0)
    vagrant@netology1:~$ file /dev/sda
    /dev/sda: block special (8/0)
    vagrant@netology1:~$ file /bin/bash
    /bin/bash: ELF 64-bit LSB shared object, x86-64
    ```
    Используя `strace` выясните, где находится база данных `file` на основании которой она делает свои догадки.
- ОТВЕТ: команда `strace -e trace=read file /bin/bash`
- РЕЗУЛЬТАТЫ показывают что БД находится здесь `\177ELF`: 
- read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 N\0\0\0\0\0\0"..., 832) = 832
- read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360q\2\0\0\0\0\0"..., 832) = 832
- read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\3003\0\0\0\0\0\0"..., 832) = 832
- read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@\"\0\0\0\0\0\0"..., 832) = 832
- read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200\"\0\0\0\0\0\0"..., 832) = 832
- read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220\201\0\0\0\0\0\0"..., 832) = 832                     = 0
- read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\4\3\0\0\0\0\0"..., 1048576) = 1048576	

- ОТВЕТ после доработки: команда `strace -e openat file /bin/bash`
- РЕЗУЛЬТАТЫ показывают что БД находится здесь 
`openat(AT_FDCWD, "/usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache", O_RDONLY) = 3`

- ОБЪЯСНЕНИЕ: 
- `read` - это чтение открытого файла с параметрами (второй аргумент - это указатель на область памяти, 
куда будут помещаться данные)
- а открытие файла производится вызовом `openat`

- ОТВЕТ после доработки от 24-11-2021: 
- база данных находится по адресу: `/usr/share/misc/magic.mgc`
- предыдущий файл `/usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache` это системный файл для преобразования символов.

3. Предположим, приложение пишет лог в текстовый файл. 
Этот файл оказался удален (deleted в lsof), 
однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. 
Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. 
Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла 
(чтобы освободить место на файловой системе).
- ДОРАБОТАННЫЙ ОТВЕТ: 
- находим процесс, который пишет в удаленный файл: `lsof +L1` или `lsof | grep deleted` 
- определяем PID (пример: 1111), файловый дескриптор (пример: 4) и имя файла (deleted.log); 
- варианты команд `> /proc/1111/fd/4` или `truncate -s 0 /proc/1111/fd/4`
- В этом случае сам файл останется в файловой системе пока процесс не завершится, 
но размер файла будет 0 байт и место на диске высвободится.

4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
ОТВЕТ: Не занимают, но блокируют записи в таблице процессов, размер которой ограничен для каждого пользователя и системы в целом.

5. В iovisor BCC есть утилита `opensnoop`:
    ```bash
    root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
    /usr/sbin/opensnoop-bpfcc
    ```
    На какие файлы вы увидели вызовы группы `open` за первую секунду работы утилиты? 
    Воспользуйтесь пакетом `bpfcc-tools` для Ubuntu 20.04. 
    Дополнительные [сведения по установке](https://github.com/iovisor/bcc/blob/master/INSTALL.md).
- ОТВЕТ: на следующие файлы:
- PID    COMM               FD ERR PATH
- 1      systemd            21   0 /proc/409/cgroup
- 797    vminfo              5   0 /var/run/utmp
- 595    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
- 595    dbus-daemon        18   0 /usr/share/dbus-1/system-services
- 595    dbus-daemon        -1   2 /lib/dbus-1/system-services
- 595    dbus-daemon        18   0 /var/lib/snapd/dbus-1/system-services/
- 611    irqbalance          6   0 /proc/interrupts
- 611    irqbalance          6   0 /proc/stat
- 611    irqbalance          6   0 /proc/irq/20/smp_affinity
- 611    irqbalance          6   0 /proc/irq/0/smp_affinity
- 611    irqbalance          6   0 /proc/irq/1/smp_affinity
- 611    irqbalance          6   0 /proc/irq/8/smp_affinity
- 611    irqbalance          6   0 /proc/irq/12/smp_affinity
- 611    irqbalance          6   0 /proc/irq/14/smp_affinity
- 611    irqbalance          6   0 /proc/irq/15/smp_affinity
- 797    vminfo              5   0 /var/run/utmp
- 595    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
- 595    dbus-daemon        18   0 /usr/share/dbus-1/system-services
- 595    dbus-daemon        -1   2 /lib/dbus-1/system-services
- 595    dbus-daemon        18   0 /var/lib/snapd/dbus-1/system-services/


6. Какой системный вызов использует `uname -a`?
Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc`, 
где можно узнать версию ядра и релиз ОС.
- ОТВЕТ: системный вызов `uname`. Также можно использовать `arch`, которая также вызывает системный 
вызов `uname`. Данные находятся по пути `/proc/sys/kernel/ {ostype, hostname, osrelease, version, domainname}`
Но в man я этого не нашел, нашел в интернете.

7. Чем отличается последовательность команд через `;` и через `&&` в bash? Например:
    ```bash
    root@netology1:~# test -d /tmp/some_dir; echo Hi
    Hi
    root@netology1:~# test -d /tmp/some_dir && echo Hi
    root@netology1:~#
    ```
    Есть ли смысл использовать в bash `&&`, если применить `set -e`?
- ОТВЕТ: 
- `&&` - оператор выполнит вторую команду только в том случае, если команда 1 успешно выполнена;
- `;` - последовательное выполнение команд без зависимости от успеха и отказа других команд;
- `set -e` - прекращает выполнение если команда возвращает не 0 код, возвращает код последней команды;
- если установлена опция `set -e` то смысла использовать `&&` практические нет, возможны какие нибудь тонкости.

	
8. Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?
- ОТВЕТ: 
- `set -euxo pipefail` - комплексная опция, включающая несколько режимов одновременно;
- `set -e` - прекращает выполнение скрипта если команда завершилась ошибкой, выводит в stderr строку с ошибкой. 
Обойти эту проверку можно добавив в пайплайн к команде true: mycommand | true.
- `set -u` - прекращает выполнение скрипта, если встретилась несуществующая переменная.
- `set -x` - выводит выполняемые команды в stdout перед выполненинем.
- `set -o pipefail` - прекращает выполнение скрипта, даже если одна из частей пайпа завершилась ошибкой. 
В этом случае bash-скрипт завершит выполнение, если mycommand вернёт ошибку, не смотря на true в конце пайплайна:
- `set -euxo pipefail` хороша особенно для начинающих и максимального контроля и прозрачности выполнения скриптов.

9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. 
В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. 
Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).
- ОТВЕТ: команда `ps ax -o pid,stat --sort stat`
- наиболее частый статус: `I, I<`
- `I`    поток ядра процессора              
- дополнительные буквы:
- `<`    высокий приоритет
- `N`    низкий приоритет
- `L`    имеет частично 
- `s`    является лидер сессии
- `l`    много поточный
- `+`    в группе процессов на переднем плане
 
 ---

