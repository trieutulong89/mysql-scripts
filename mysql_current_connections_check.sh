#!/bin/bash 

#Author vannt2@eway.vn

set -e #Exit scipt if variable is not set.

usage() {
    echo "Script check current mysql connections."
    echo "Usage: $0 -w number -c number"
    exit 1;
}

if [[ -z $1 ]]; then
    usage
fi

while getopts "w:c:" option;
do
    case "${option}" in
        w)
            warning=${OPTARG}
            ;;
        c)
            critical=${OPTARG}
            ;;
        *)
            usage
            exit
            ;;
done            

# check if not number input

number='^[0-9]+$'

if [[ $2 =~ $number && $4 =~ $number ]]; then
    echo "Invalid input: Not a number";
    usage
    exit
fi

warn=$2
crit=$4

mysql --defaults-file=/etc/mysql/debian.cnf -e "select count(id) from information_schema.processlist;" 1>&2 > /dev/null

if [[ $? -ne 0 ]]; then
    echo "Critical, too many connections on mysql."
    exit 2
fi

current_connect=${mysql --defaults-file=/etc/mysql/debian.cnf -e "select count(id) from information_schema.processlist;" | grep "[0-9]"}

if [[ $current_connect -ge $crit ]]; then
    echo "Critical! Current connections on mysql: $current_connect"
    exit 2
elif [[ $current_connect -ge $warn ]]; then
    echo "Warning! Current connections on mysql: $current_connect"
    exit 1
else
    echo "OK! Current connections on mysql: $current_connect"
fi    
