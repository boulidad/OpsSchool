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
TMP_CREDENTIAL_FILE=~/.aws/MFA_credentials
ERROR_FILE=/tmp/mfa_error_$$
touch ${ERROR_FILE}

# check jq is installed
jq --version > /dev/null 2>&1
if [ $? -ne 0 ]
then
   echo
   echo "! you must install jq for this script."
   echo
   echo "to install jq run the following command:"
   echo "Mac:     brew install jq"
   echo "ubuntu:  sudo apt-get install jq"
   echo "CentOs:  sudo yum install jq -y"
   echo "RedHat:  sudo snap install jq"
   echo "Windows: May God be with you"
   echo
   exit
fi

if [ $? -ne 0 ]; 
   then
       echo -e "\nAWS CLI is not installed; exiting\n"
elif [ $# -lt 1 ]
   then
        echo -e "\nusage:  source ${HOME}/.aws/set_MFA_credentials.sh  <TOKEN>\n"
elif  [ -z "${AWS_ID}" -o -z "${AWS_USERNAME}" ]
   then
       echo -e "\nThe following variables must be set and exported:"
       echo -e "  AWS_ID"
       echo -e "  AWS_USERNAME\n"       
else
	unset AWS_ACCESS_KEY_ID
	unset AWS_SECRET_ACCESS_KEY
	unset AWS_SECURITY_TOKEN
	unset AWS_SESSION_TOKEN
	token=$1
	TMP=/tmp/sts-$$.json
	aws  sts get-session-token --serial-number arn:aws:iam::${AWS_ID}:mfa/${AWS_USERNAME}  --token-code ${token} >$TMP 2>${ERROR_FILE}
        if [ $? -ne 0 ]
        then
          echo
          echo "failed to get session token !! try again"
          echo
          printf "Error Message:"
          cat ${ERROR_FILE}
          echo
        else
	  export AWS_ACCESS_KEY_ID=`jq '.Credentials.AccessKeyId' <$TMP| sed -e 's/"//g'`
	  export AWS_SECRET_ACCESS_KEY=`jq '.Credentials.SecretAccessKey' <$TMP| sed -e 's/"//g'`
	  export AWS_SECURITY_TOKEN=`jq '.Credentials.SessionToken' <$TMP| sed -e 's/"//g'`
	  export AWS_SESSION_TOKEN=`jq '.Credentials.SessionToken' <$TMP| sed -e 's/"//g'`
          echo "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"         >  ${TMP_CREDENTIAL_FILE}
          echo "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> ${TMP_CREDENTIAL_FILE}
          echo "export AWS_SECURITY_TOKEN=${AWS_SECURITY_TOKEN}"       >> ${TMP_CREDENTIAL_FILE}
          echo "export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}"       >> ${TMP_CREDENTIAL_FILE}
          echo
          echo "your mfa was set, you can start using aws-cli"
          echo
        fi
fi
rm ${ERROR_FILE}
