#!/bin/bash
if [ $# -lt 3 ]
then
        echo "usage: $0 [ SERVER_LIST_FILE ] [ parallelizem ] [ COMMAND_TO_RUN (in quotes) ] CLEAN "
        exit 1
fi
SERVER_LIST=$1
PARALLELIZEM=$2
COMMAND_TO_RUN="$3"
CLEAN=`echo $4 | tr '[:lower:]' '[:upper:]'  `

P_COUNTER=1


checkParallelizem(){
  if [ ! ${P_COUNTER} ]
   then
    P_COUNTER=0
  fi

  P_COUNTER=`echo ${P_COUNTER}+1|bc`
  if [ ${P_COUNTER} -eq ${PARALLELIZEM} ]
   then
    wait
    sleep 2
    P_COUNTER=0
  fi

}


runOneCommand(){
  RESALT=`ssh  -o NumberOfPasswordPrompts=0 $1 "$2" 2>runParallel.eerr`
  STATUS=$?
  if [ "${CLEAN}" = "CLEAN" ]
  then
     THE_HOST=""
  else
     THE_HOST="$1 - "
  fi
  if [ ${STATUS} -eq 0 ]
  then
     echo "${THE_HOST}$RESALT"
  else
     echo "${THE_HOST} Error - ${STATUS}"
  fi
}

for i in `cat $SERVER_LIST`
  do
    runOneCommand $i "$COMMAND_TO_RUN" & 
    checkParallelizem
done


wait 
