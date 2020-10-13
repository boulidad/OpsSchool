#!/bin/bash
SET_MFA_CREDENTIALS_SCRIPT=${HOME}/.aws/set_MFA_credentials.sh
BASH_PROFILE=${HOME}/.bash_profile
ZSHRC=${HOME}/.zshrc

####################################################################################
#  get user data 
###################################################################################
clear
echo "####################################################################################"
echo " MFA client setup"
echo "####################################################################################"
echo
printf "please write your AWS_ID - (company id): "
read AWS_ID

printf "please type your AWS username: "
read AWS_USERNAME

####################################################################################
#  get concent 
###################################################################################
clear
echo "####################################################################################"
echo " MFA client setup"
echo "####################################################################################"
echo 
echo "this script will do the following:"
echo "1. create a file '${SET_MFA_CREDENTIALS_SCRIPT}' - this file will later be used to get MFA cestificate"
echo "2. add to your '${BASH_PROFILE}' source to a tmp creadatial file, so once you aythenticate other sessions will get the credatioans from there"
echo "3. add AWS_USERNAME and AWS_ID to '${BASH_PROFILE}'"
echo "4. if you have ~/.zshrc, it will push it the source ,alias command and env vars to"
echo 
echo
echo
echo "your AWS_USERNAME is: '${AWS_USERNAME}'"
echo "your AWS_ID is:       '${AWS_ID}'"
echo
echo "do you want to continue?"
select answer in yes no
do
  case ${answer} in
  no) echo "you chose not to proceed"
        exit;;
  yes) echo "You have chosen $answer"
         break;;
  * ) echo "you must pick 1 or 2"
      echo ${answer};;
  esac
done

####################################################################################
#  create the set_MFA_credentials.sh script
###################################################################################
cat > ${SET_MFA_CREDENTIALS_SCRIPT}  << 'EOF'
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
EOF

###################################################################################
#  pushing to ~/.bash_profile
###################################################################################
cat >> ${BASH_PROFILE}  << 'EOF'

# this is inserted by gen_set_MFA_credentials.sh script
MFA_CREDENTIALS_FILE=${HOME}/.aws/MFA_credentials
if [ -f "${MFA_CREDENTIALS_FILE}" ]; then
    source ${MFA_CREDENTIALS_FILE}
fi
alias aws_mfa="source ${HOME}/.aws/set_MFA_credentials.sh"
EOF
echo "export AWS_USERNAME=${AWS_USERNAME}" >>  ${BASH_PROFILE}
echo "export AWS_ID=${AWS_ID}" >>  ${BASH_PROFILE}



###################################################################################
#  pushing to ~/.zshrc if exists
###################################################################################

if [ -f ${ZSHRC} ] 
then
cat >> ${ZSHRC}  << 'EOF'

# this is inserted by gen_set_MFA_credentials.sh script
MFA_CREDENTIALS_FILE=${HOME}/.aws/MFA_credentials
if [ -f "${MFA_CREDENTIALS_FILE}" ]; then
    source ${MFA_CREDENTIALS_FILE}
fi
alias aws_mfa="source ${HOME}/.aws/set_MFA_credentials.sh"
EOF
echo "export AWS_USERNAME=${AWS_USERNAME}" >>  ${ZSHRC}
echo "export AWS_ID=${AWS_ID}" >>  ${ZSHRC}
fi


echo
echo "files created."
echo "in order to start using MFA, you need to start a new session, then run this command"
echo "aws_mfa  <YOUR_MFA_TOKEN>"
echo
