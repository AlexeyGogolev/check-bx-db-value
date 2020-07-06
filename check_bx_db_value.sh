#!/bin/bash
#
# Site: https://github.com/AlexeyGogolev/check-bx-db-value
#
mysql="$(which mysql)" # получение пути к mysql
php="$(which php)" # получение пути к php
declare -A CLParams # массив значений параметров КС
declare -a CLParams_keys # массив ключей для массива параметров КС
declare -A DBSettings # массив значений переменных конфига
declare -a DBSettings_keys # массив ключей для массива значений переменных конфига
DBSettings_keys=(DBLogin DBPassword DBName)
CLParams_keys=(path_to_bxdb_config single_num_value_query max_num_value)
param_num=0 # счетчик параметров КС
# получение параметров КС
for key in "${CLParams_keys[@]}" ; do 
    ((param_num++))                 
    CLParams[$key]=${!param_num}    # ${!param_num} здесь генери-т $1 $2... 
done
# если нет последнего параметра, показываем справку
if  [ -z "${CLParams[${CLParams_keys[$param_num-1]}]}" ] ; then
    printf "Script compares result returned by <${CLParams_keys[1]}> to given <${CLParams_keys[2]}>.\nIf the result more than the given value, then exit with code 1, else exit 0.\n"
    printf "Usage: \n\t$(basename ${BASH_SOURCE[0]}) " ; for key in "${CLParams_keys[@]}" ; do printf "<$key> "; done ; printf "\n"
    printf "Example: \n\t$(basename ${BASH_SOURCE[0]}) \"/www/ab.cd/bitrix/php_interface/dbconn.php\" \"select count(id) from b_event where SUCCESS_EXEC<>'Y'\" 5\n" 
    exit 10
fi
# выход если конфиг пустой или его нет 
if ! [ -s "${CLParams[path_to_bxdb_config]}" ] ; then 
    printf "File ${CLParams[path_to_bxdb_config]} doesn't exist or empty.\n"
    exit 20
fi
# выход если параметр запроса к БД содержит команду из "запретного списка"
echo ${CLParams[single_num_value_query]} | grep -i -q -E 'delete|update|insert|drop' && printf "query \n${CLParams[single_num_value_query]}\nisn't allowed\n" && exit 30
# получение значений переменных из php-config -n -- без php.ini , -r -- выполнить код без тэгов <?...?>
for key in "${DBSettings_keys[@]}" ; do 
    DBSettings[$key]="$($php -n -r 'include("'${CLParams[path_to_bxdb_config]}'"); print $'$key';')"
done
# экспорт пароля mysql в переменную окружения (по соображениям безопасности)
export MYSQL_PWD=${DBSettings[DBPassword]}
# получение одиночного значения из БД: -N -- без названий колонок ; -B - (batch) - результаты без "бокса" вокруг значений; -e выполнить запрос
num_value=`${mysql} -u ${DBSettings[DBLogin]} -N -B -e "use ${DBSettings[DBName]}; ${CLParams[single_num_value_query]}"`
# отображение значений
echo "Result of the query (from DB ${DBSettings[DBName]}): ${num_value}, ${CLParams_keys[2]}: ${CLParams[max_num_value]}"
# сравнение значений
if [ $num_value -gt ${CLParams[max_num_value]} ]; then
    exit 1
fi
