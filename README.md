# Checking value from bitrix database

Script compares result returned by <single_num_value_query> to given <max_num_value>.
If the result more than the given value, then it exits with code 1 (otherwise normal exit).

Useful to check unsent messages, especially with [monit](https://mmonit.com/monit/) utility.

### Usage:
```console
$ check_bx_db_value.sh <path_to_bxdb_config> <single_num_value_query> <max_num_value>
```
### Example (content of script somedb_unsent_check.sh):
```bash
check_bx_db_value.sh "/www/ab.cd/bitrix/php_interface/dbconn.php" "select count(id) from b_event where SUCCESS_EXEC<>'Y'" 2
```
### Example of Monit configuration (for the script above):

```bash
check program somedb_unsent_check with path /somepath/mail_check/somedb_unsent_check.sh
every 240 cycles
    group mail
if status != 0 then alert
```
### Example of Monit output:
![Monit output](https://github.com/AlexeyGogolev/check-bx-db-value/blob/master/monit_output.png?raw=true)