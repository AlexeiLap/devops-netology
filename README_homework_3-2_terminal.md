# Домашнее задание к занятию "3.2. Работа в терминале, лекция 2"

1. Какого типа команда `cd`? Попробуйте объяснить, почему она именно такого типа; 
опишите ход своих мыслей, если считаете что она могла бы быть другого типа.
- ОТВЕТ: cd is a shell builtin, команда встроенной оболочки, базовая команда для перемещения по файловой системе, 
нужна для работы самой оболочки.

2. Какая альтернатива без pipe команде `grep <some_string> <some_file> | wc -l`? `man grep` 
поможет в ответе на этот вопрос. Ознакомьтесь с [документом](http://www.smallo.ruhr.de/award.html) 
о других подобных некорректных вариантах использования pipe.
- ОТВЕТ: grep <some_string> <some_file> -c
- с другими некорректными вариантами использования pipe ознакомился.

3. Какой процесс с PID `1` является родителем для всех процессов в вашей виртуальной машине Ubuntu 20.04?
- ОТВЕТ: `systemd`

4. Как будет выглядеть команда, которая перенаправит вывод stderr `ls` на другую сессию терминала?
- ОТВЕТ: `ls -l /root/ 2>/dev/pts/0` 

5. Получится ли одновременно передать команде файл на stdin и вывести ее stdout в другой файл? Приведите работающий пример.
ответ:
-есть файл error.log
-передаем его на вход и результат на выход в другой файл - cat error.log > error2.log

6. Получится ли вывести находясь в графическом режиме данные из PTY в какой-либо из эмуляторов TTY? 
Сможете ли вы наблюдать выводимые данные?
- ОТВЕТ: Да, получилось, `echo test >/dev/tty1`

7. Выполните команду `bash 5>&1`. К чему она приведет? Что будет, если вы выполните `echo netology > /proc/$$/fd/5`?
Почему так происходит?
- ОТВЕТ: В командной оболочке 5 поток перенаправляет в первый. 0,1,2 стандартные потоки а можно создать еще свои.
Вторая команда отправляет вывод в 5 поток, потому что потоки тоже файлы.
А поскольку 5 перенаправлен в 1, то произойдет стандартный вывод. 

8. Получится ли в качестве входного потока для pipe использовать только stderr команды, не потеряв при этом отображение 
stdout на pty? Напоминаем: по умолчанию через pipe передается только stdout команды слева от `|` на stdin команды справа.
Это можно сделать, поменяв стандартные потоки местами через промежуточный новый дескриптор, 
который вы научились создавать в предыдущем вопросе.
- ОТВЕТ: без смены дескрипторов открыть несущ файл `cat 3 2>&1 | grep a` 
отразит ошибку если файла `3` нет, а если файл `3` есть отразит его содержание с поиском `а`
С перенаправлением наверное так будет: `cat 3 6<&1 2>&1 0<&6 | grep a`

9. Что выведет команда `cat /proc/$$/environ`? Как еще можно получить аналогичный по содержанию вывод?
- ОТВЕТ: просмотр переменных оболочки поскольку $$ - идентификатор процесса оболочки,
можно сделать через команду `printenv`

10. Используя `man`, опишите что доступно по адресам `/proc/<PID>/cmdline`, `/proc/<PID>/exe`.
- ОТВЕТ: `/proc/<PID>/cmdline` - параметры командной строки, переданные исполняемому файлу при запуске процесса 
c PID; `/proc/<PID>/exe` - является символьной ссылкой на исполненный бинарный файл c <PID>

11. Узнайте, какую наиболее старшую версию набора инструкций SSE поддерживает ваш процессор с помощью `/proc/cpuinfo`.
- ОТВЕТ: `cat /proc/cpuinfo | grep sse`
- поддерживаемые версии: от `sse2` до `sse4_2`

12. При открытии нового окна терминала и `vagrant ssh` создается новая сессия и выделяется pty. 
	Это можно подтвердить командой `tty`, которая упоминалась в лекции 3.2. Однако:
    ```bash
	vagrant@netology1:~$ ssh localhost 'tty'
	not a tty
    ```
	Почитайте, почему так происходит, и как изменить поведение.
- ОТВЕТ: Не нашел ответа. Вроде можно в команде vagrant ssh передавать дополнительный аргумент -t или -tt 
    для принудительного создавания tty.	
	
13. Бывает, что есть необходимость переместить запущенный процесс из одной сессии в другую. 
Попробуйте сделать это, воспользовавшись `reptyr`. 
Например, так можно перенести в `screen` процесс, который вы запустили по ошибке в обычной SSH-сессии.
- ОТВЕТ: попробовал
`$ disown <your process name>          # Detach process from the shell`
`$ screen                # Launch screen`
`$ reptyr $(pgrep irssi) # Get back the process`

14. `sudo echo string > /root/new_file` не даст выполнить перенаправление под обычным пользователем, 
так как перенаправлением занимается процесс shell'а, который запущен без `sudo` под вашим пользователем. 
Для решения данной проблемы можно использовать конструкцию `echo string | sudo tee /root/new_file`. 
Узнайте что делает команда `tee` и почему в отличие от `sudo echo` команда с `sudo tee` будет работать.
- ОТВЕТ: T — команда tee linux принимает данные из одного источника и может сохранять их на выходе в нескольких местах
echo 'a' | tee b, он напишет "a" в файл b и отобразит вывод (эхо-выход) в терминале.
Но особенность команды tee в том, что она не только допишет файл, но ещё и выведет добавленную строку в консоль. 
Если вы не хотите, чтобы данные вновь возвращались в консоль, то сделайте редирект вывода на /dev/null.
 ---
