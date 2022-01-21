
# Домашнее задание к занятию "5.1. Введение в виртуализацию. Типы и функции гипервизоров. Обзор рынка вендоров и областей применения."

## Задача 1

Опишите кратко, как вы поняли: в чем основное отличие полной (аппаратной) виртуализации, паравиртуализации и виртуализации на основе ОС.

Ответ:
- полная (аппаратная) виртуализация - не нужна операционная система
сами гипервизоры являются операционными системами и они обеспечивают взаимодействие между 
виртуальными машинами и аппаратными средствами сервера;
- паравиртуализация - нужна операционная система, установленная на сервере,
гипервизор обеспечивает независимую работу различных виртуальных машин, 
гипервизор управляет гостевыми системами для разделения доступа к аппаратным ресурсам;
виртуальные машины могут работать на разных ОС отличных от базовой;
- виртуализация уровня ОС - нужна операционная система, виртуальные машины будут
независимыми но такого же типа как и основная система, гипервизор обеспечивает изоляцию
и распределение аппаратных ресурсов.


## Задача 2

Выберите один из вариантов использования организации физических серверов, в зависимости от условий использования.

Организация серверов:
- физические сервера,
- паравиртуализация,
- виртуализация уровня ОС.

Условия использования:
- Высоконагруженная база данных, чувствительная к отказу- лучше выделять физические сервера
они обеспечат максимальную производительность и надежность и безопасность;
- Различные web-приложения - паравиртуализация поскольку для разных приложений
может требоваться изолированные системы и могут быть разные ядра для операционных систем;
- Windows системы для использования бухгалтерским отделом - виртуализация уровня ОС - поскольку ядро одно
то можно использовать данный тип который позволит создать изолированные машины;
- Системы, выполняющие высокопроизводительные расчеты на GPU - если ядро у систем одно,
то возможно виртуализация уровня ОС чтобы ядра новые не создавались, если ядра у систем разные
то паравиртуализация, аппаратная вряд ли подойдет, поскольку нужно делить одно GPU между разными системами.

Опишите, почему вы выбрали к каждому целевому использованию такую организацию.

## Задача 3

Выберите подходящую систему управления виртуализацией для предложенного сценария. Детально опишите ваш выбор.

Сценарии:

1. 100 виртуальных машин на базе Linux и Windows, общие задачи, нет особых требований. Преимущественно Windows based инфраструктура, требуется реализация программных балансировщиков нагрузки, репликации данных и автоматизированного механизма создания резервных копий.
- выбираем Hyper-V он Windows ориентирован;
- имеет отдельные компоненты для миграции и репликации;
- упрощенное управление драйверами, широкий диапазон поддержки что 
пригодится когда 100 виртуальных разных машин;
2. Требуется наиболее производительное бесплатное open source решение для виртуализации небольшой (20-30 серверов) инфраструктуры на базе Linux и Windows виртуальных машин.
- выбираем KVM как современное, бесплатное решение
- с драйвером virtio обеспечивает производительность близкую к нативной
3. Необходимо бесплатное, максимально совместимое и производительное решение для виртуализации Windows инфраструктуры.
- выбираем Xen PV как наиболее стабильное, универсальное и надежное решение
4. Необходимо рабочее окружение для тестирования программного продукта на нескольких дистрибутивах Linux.
- выбираем VitrualBox и Vagrant как наиболее распространненные и известных продукты,
которые быстро развернуть и свернуть и удобно управлять и много информации по настройками.

## Задача 4

Опишите возможные проблемы и недостатки гетерогенной среды виртуализации (использования нескольких систем управления виртуализацией одновременно) и что необходимо сделать для минимизации этих рисков и проблем. Если бы у вас был выбор, то создавали бы вы гетерогенную среду или нет? Мотивируйте ваш ответ примерами.

- непонятно как они между собой будут контактировать и совместно работать;
- но если задачи будут специфическими чтобы ряд задач решался в рамках одной системы а другие в рамках
другой то возможно в этой будет смысл;
- это стоит делать если есть специфические задачи и понятно для чего это реализуется,
как правило это усложнение, сложность поддерживать такое решение;
- больше трудоемкость, больше персонала нужно с разными навыками;
- но например если как в примере много Windows систем для бухотдела и одна-две Linux
то можно использовать гетерогенную среду в которой будет несколько систем управления
виртуализацией одна будет управления Windows системами, другая несколькими разными Linux.