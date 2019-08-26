#!/bin/bash
if [ $# -lt 1 ]
   then
        echo
        echo "usage:    $0 [ FILE_OR_DIRE_TO_COPY ] [  SERVER_LIST_FILE ] "
        echo 
        exit 99
fi

whatToCopy=$1
whereToCopyFile=$2

if [ ! -e ${whatToCopy} ]
then
        echo 
        echo "  cant find file \"${whatToCopy}\" "
        echo 
        exit 99
fi


if [ ! -a ${whereToCopyFile} ]
then
        echo 
        echo "  cant find server list file \"${whereToCopyFile}\" "
        echo 
        exit 99
fi



LOG_DIR=${HOME}/logs/scpLog$$
mkdir -p ${LOG_DIR}

scpOne(){
  scp -r ${whatToCopy} $1:  > ${LOG_DIR}/pscp.$1
  echo "$1 $?"
}

for SERVER_TO_COPY in `cat ${whereToCopyFile}`
do
    scpOne ${SERVER_TO_COPY} &
done
