#!/bin/bash
if [ $# -ne 2 ]
   then
        echo -e "\nusage:  $0 DB_IDENTIFIER REGION\n"
	exit	
fi
DB_IDENTIFIER=$1
REGION=$2
aws rds describe-db-log-files --db-instance-identifier ${DB_IDENTIFIER}  --region ${REGION}
