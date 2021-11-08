# Домашнее задание к занятию «2.4. Инструменты Git»

1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.

- команда: git show aefea
- хэш: aefead2207ef7e2aa5dc81a34aedf0cad4c32545
- комментарий: Update CHANGELOG.md  

3. Какому тегу соответствует коммит `85024d3`?
- команда: git show 85024d3
- хэш 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)
- tag: v0.12.23

4. Сколько родителей у коммита `b8d720`? Напишите их хеши.

- команды:
- git log b8d720 --pretty=format:"%h %s parents: %P" -1
- git show b8d720 --pretty=format:"%h %s parents: %P"
- git show b8d720 --pretty=format:"%P"
- результаты:
- 56cd7859e05c36c06b56d013b55a252d0bb7e158 9ea88f22fc6269854151c571162c5bcf958bee2b

6. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами  v0.12.23 и v0.12.24.

- команда: git log --oneline v0.12.23..v0.12.24
- результаты:
- 33ff1c03b (tag: v0.12.24) v0.12.24
- b14b74c49 [Website] vmc provider links
- 3f235065b Update CHANGELOG.md
- 6ae64e247 registry: Fix panic when server is unreachable
- 5c619ca1b website: Remove links to the getting started guide's old location
- 06275647e Update CHANGELOG.md
- d5f9411f5 command: Fix bug when using terraform login on Windows
- 4b6d06cc5 Update CHANGELOG.md
- dd01a3507 Update CHANGELOG.md
- 225466bc3 Cleanup after v0.12.23 release

8. Найдите коммит в котором была создана функция `func providerSource`, ее определение в коде выглядит 
так `func providerSource(...)` (вместо троеточего перечислены аргументы).

- команда: git log -S"func providerSource" --oneline
- результаты:
- добавлено Thu Apr 2 18:04:39 2020 8c928e835 main: Consult local directories as potential mirrors of providers
- переделка Tue Apr 21 16:28:59 2020 5af1e6234 main: Honor explicit provider_installation CLI config when present


10. Найдите все коммиты в которых была изменена функция `globalPluginDirs`.

- находим в каком файле функция: git grep -n "func globalPluginDirs"
- результат: plugins.go:18:func globalPluginDirs() []string

- ищем изменение тела функции: git log -L :globalPluginDirs:plugins.go
- результаты:
- commit 8364383c359a6b738a436d1b7745ccdce178df47 - Добавлена функция;
- commit 66ebff90cdfaa6938f26f908c7ebad8d547fea17 - изменена;
- commit 41ab0aef7a0fe030e84018973a64135b11abcd70 - изменена;
- commit 52dbf94834cb970b510f2fba853a5b49ad9b1a46 - изменена;
- commit 78b12205587fe839f10d946ea3fdc06719decb05 - изменена;

12. Кто автор функции `synchronizedWriters`? 

- команда: git log -S"func synchronizedWriters" --oneline
- результаты: 
- bdfea50cc remove unused
- 5ac311e2a main: synchronize writes to VT100-faker on Windows

git show 5ac311e2a
- добавлено в коммите 5ac311e2a Author: Martin Atkins <mart@degeneration.co.uk>

git show bdfea50cc
- удалена коммитом bdfea50cc85161dea41be0fe3381fd98731ff786 Author: James Bardin <j.bardin@gmail.com>