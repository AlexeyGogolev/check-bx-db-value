#!/bin/bash
$(dirname ${BASH_SOURCE[0]})/check_bx_db_value.sh "/www/ab.cd/bitrix/php_interface/dbconn.php" "select count(id) from b_event where SUCCESS_EXEC<>'Y'" 2