#!/bin/bash
#
# Site: https://github.com/AlexeyGogolev/check-bx-db-value
#
mysql="$(which mysql)"
php="$(which php)"
declare -A CLParams
declare -a CLParams_keys
declare -A DBSettings
declare -a DBSettings_keys
DBSettings_keys=(DBLogin DBPassword DBName)
CLParams_keys=(path_to_bxdb_config single_num_value_query max_num_value)
param_num=0
# getting command line arguments
for key in "${CLParams_keys[@]}" ; do 
    ((param_num++))    
    CLParams[$key]=${!param_num}    
done
# if no last CL argument then show description 
if  [ -z "${CLParams[${CLParams_keys[$param_num-1]}]}" ] ; then
    printf "Script compares result returned by <${CLParams_keys[1]}> to given <${CLParams_keys[2]}>.\nIf the result more than the given value, then exit with code 1, else exit 0.\n"
    printf "Usage: \n\t$(basename ${BASH_SOURCE[0]}) " ; for key in "${CLParams_keys[@]}" ; do printf "<$key> "; done ; printf "\n"
    printf "Example: \n\t$(basename ${BASH_SOURCE[0]}) \"/www/ab.cd/bitrix/php_interface/dbconn.php\" \"select count(id) from b_event where SUCCESS_EXEC<>'Y'\" 5\n" 
    exit 10
fi
# exit if no/empty config
if ! [ -s "${CLParams[path_to_bxdb_config]}" ] ; then 
    printf "File ${CLParams[path_to_bxdb_config]} doesn't exist or empty.\n"
    exit 20
fi
# exit with error message if query-argument has command from the restriction list (below)
echo ${CLParams[single_num_value_query]} | grep -i -q -E 'delete|update|insert|drop' && printf "query \n${CLParams[single_num_value_query]}\nisn't allowed\n" && exit 30
# getting values of variables from given php-config -n -- no php.ini , -r -- execute given code
for key in "${DBSettings_keys[@]}" ; do 
    DBSettings[$key]="$($php -n -r 'include("'${CLParams[path_to_bxdb_config]}'"); print $'$key';')"
done
# exporting mysql password into env varible (due to security reasons)
export MYSQL_PWD=${DBSettings[DBPassword]}
# getting single value from DB: -N -- no column names ; -B - (batch) - results with no "boxing"; -e execute statement
num_value=`${mysql} -u ${DBSettings[DBLogin]} -N -B -e "use ${DBSettings[DBName]}; ${CLParams[single_num_value_query]}"`
# displaying the values
echo "Result of the query (from DB ${DBSettings[DBName]}): ${num_value}, ${CLParams_keys[2]}: ${CLParams[max_num_value]}"
# Comparison of the values
if [ $num_value -gt ${CLParams[max_num_value]} ]; then
    exit 1
fi
