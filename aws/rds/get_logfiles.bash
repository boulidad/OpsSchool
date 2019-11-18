#!/bin/bash
if [ $# -ne 3 ]
   then
        echo -e "\nusage:  $0 DB_IDENTIFIER REGION LOGFILE_NAME\n"
	exit	
fi
DB_IDENTIFIER=$1
REGION=$2
LOGFILE_NAME=$3
aws rds download-db-log-file-portion --db-instance-identifier ${DB_IDENTIFIER} --log-file-name "${LOGFILE_NAME}"  --starting-token 0 --output text --region ${REGION}
