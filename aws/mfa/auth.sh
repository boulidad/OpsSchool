#!/bin/bash
#!/usr/bin/bash
#
#  script for AWS MFA
#  
#  the script expects two env variables
#  AWS_ID
#  AWS_USERNAME
#
#
AWS_CLI=`which aws`
if [ $? -ne 0 ]; 
   then
       echo -e "\nAWS CLI is not installed; exiting\n"
elif [ $# -lt 1 ]
   then
        echo -e "\nusage:  source  auth.sh TOKEN\n"
elif  [ -z "${AWS_ID}" -o -z "${AWS_USERNAME}" ]
   then
       echo -e "\nThe following variables must be set and exported:"
       echo -e "  AWS_ID"
       echo -e "  AWS_USERNAME\n"       
elif [ "${0}" != '-bash' ]
   then
       echo -e "\n! make sure you run script with 'source' and not directlly\n"
else
	unset AWS_ACCESS_KEY_ID
	unset AWS_SECRET_ACCESS_KEY
	unset AWS_SECURITY_TOKEN
	unset AWS_SESSION_TOKEN
	token=$1
	TMP=/tmp/sts-$$.json
	aws  sts get-session-token --serial-number arn:aws:iam::${AWS_ID}:mfa/${AWS_USERNAME}  --token-code ${token} >$TMP
	export AWS_ACCESS_KEY_ID=`jq '.Credentials.AccessKeyId' <$TMP| sed -e 's/"//g'`
	export AWS_SECRET_ACCESS_KEY=`jq '.Credentials.SecretAccessKey' <$TMP| sed -e 's/"//g'`
	export AWS_SECURITY_TOKEN=`jq '.Credentials.SessionToken' <$TMP| sed -e 's/"//g'`
	export AWS_SESSION_TOKEN=`jq '.Credentials.SessionToken' <$TMP| sed -e 's/"//g'`
fi

