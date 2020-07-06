# Проверка значения из БД Битрикса

Скрипт читает конфиг сайта Битрикса ( <path_to_bxdb_config> ), делает запрос ( <single_num_value_query> ) к его БД, сравнивает результат возвращенный запросом с заданной величиной ( <max_num_value> ).
Если результат больше заданной величины, выполняется выход с кодом ошибки (иначе нормальное завершение).

Может быть полезен для проверки неотправленных сообщений в БД Битрикс, особено с утилитой [monit](https://mmonit.com/monit/).

### Использование:
```console
$ check_bx_db_value.sh <path_to_bxdb_config> <single_num_value_query> <max_num_value>
```
### Пример вызова (содержимое скрипта ab_cd_unsent_check.sh):
```bash
check_bx_db_value.sh "/www/ab.cd/bitrix/php_interface/dbconn.php" "select count(id) from b_event where SUCCESS_EXEC<>'Y'" 2
```
### Пример конфигурации для Monit:

```bash
check program ab_cd_unsent_check with path /home/bitrix/scripts/ab_cd_unsent_check.sh
every 2 cycles
    group mail
if status != 0 then alert
```
### Пример вывода Monit:
![Monit output](https://github.com/AlexeyGogolev/check-bx-db-value/blob/master/monit_output.png?raw=true)