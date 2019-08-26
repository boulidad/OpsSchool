#!/bin/bash

aboutFunctions(){
########################################################################
#
#  mySqlReplicator [ aboutFunctions ]
#
#  this function prints the comment section of each funttion in
#  mySqlReplicator
#
########################################################################

  case $ORACLE_TRACE in
    T) set -x
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        PROCESS_TRACE="aboutFunctions:${PROCESS_TRACE}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        ;;
  esac

       clear
       #SCRIPT_FULL_PATH=`which ${FULL_SCRIPT_NAME} `
       echo "select the function in mySqlReplicator you want to know more about:";echo
       select FUNCTION in `grep \(\){ ${FULL_SCRIPT_NAME}|${AWK} -F\( '{print $1}'`
         do
               echo;echo
               if [ "${FUNCTION}" = "" ]
                  then
                       echo "Ohhhh nu !!!"
                       exitProcess 999
               fi

               COUNTER=`grep -n ${FUNCTION}\(\){ ${FULL_SCRIPT_NAME}|${AWK} -F: '{print $1}'`
               fromPoint=`echo ${COUNTER}+1|bc`
               echo ${FUNCTION}
               tail +${fromPoint} ${FULL_SCRIPT_NAME} |head -150 > ${TMP_FILE}
               while read -r LINE
                 do
                       TEST=`echo ${LINE}|grep ^#`
                       if [ "${TEST}" = "" ]
                          then
                               echo;echo
                               exitProcess 999
                       else
                               echo ${LINE}
                       fi
               done <  ${TMP_FILE}
       done
       exitProcess 1974
}

checkPbzip2(){
	echoLog "check version of pbzip2"
	pbzip2 -V
	checkError $? "pbzip2 not installed, for compression you need to install pbzip2"
}


listError(){
##############################################################################################################
#  check error get 2 parameters
#  1) status that it supose to check (if = 0 then it does nothing else it exits)
#  2) string to echo incase that the status != 0 (in such case it exits the program)
##############################################################################################################

        if [ $1 -ne 0 ]
        then
                echo >> ${MAIN_LOG} 2>&1
                echo "################################################################################"  >> ${MAIN_LOG} 2>&1
                echo "~#        $2"                                                                      >> ${MAIN_LOG} 2>&1
                ERRORS_IN_FILE=`cat ${ERROR_FILE}|wc -l `
                if [ ${ERRORS_IN_FILE} -ne 0 ]
                  then
                    echo "#- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --" >> ${MAIN_LOG} 2>&1
                    printf "#  " >> ${MAIN_LOG} 2>&1
                fi
                    cat ${ERROR_FILE}                                                                       >> ${MAIN_LOG} 2>&1
                echo "################################################################################"  >> ${MAIN_LOG} 2>&1
        fi
        rm ${ERROR_FILE}
        touch ${ERROR_FILE}
}

checkError(){
##############################################################################################################
#  check error get 2 parameters
#  1) status that it supose to check (if = 0 then it does nothing else it exits)
#  2) string to echo incase that the status != 0 (in such case it exits the program)
##############################################################################################################

        if [ $1 -ne 0 ]
        then
                echo >> ${MAIN_LOG} 2>&1
                echo "################################################################################"  >> ${MAIN_LOG} 2>&1
                echo "~#        $2"                                                                      >> ${MAIN_LOG} 2>&1
                ERRORS_IN_FILE=`cat ${ERROR_FILE}|wc -l `
                if [ ${ERRORS_IN_FILE} -ne 0 ]
                  then
                    echo "#- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --" >> ${MAIN_LOG} 2>&1
                    printf "#  " >> ${MAIN_LOG} 2>&1
                fi
                    cat ${ERROR_FILE}                                                                       >> ${MAIN_LOG} 2>&1
                echo "################################################################################"  >> ${MAIN_LOG} 2>&1

                exitProcess $1 "${2}"
        fi
        rm ${ERROR_FILE}
        touch ${ERROR_FILE}
}

checkInput(){
######################################################################################################
#  this procedure is for checking that the number of arguments are in the main call is OK
#  it gets three Parameters
#  1) number of arguments requiered
#  2) number of arguments gotten
#  3) Error message
######################################################################################################
        put=$1
        req=$2
        Message=$3
        if [ $put -lt $req ]
            then
              echo
              echo "============================================================================"
              DISPLAY_MESSAGE "    $Message"
              echo "============================================================================"
              echo
              exitProcess 1974
        fi

}

dumpError(){
##############################################################################################################
#  dump Error get 3 parameters
#    1) status that it supose to check
#    2) error message
#    3) dumpError_GLOBAL_PARAM
#  the procedure checks the parameter and if is diferent then 1 it write to File (parameter 3)
#  the message it gets as parameter 2
#  if status is not 0 then it changes WORNING_STATUS to 1
##############################################################################################################
#set -x debug Yaron
  case $ORACLE_TRACE in
    T) set -x
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        PROCESS_TRACE="logError:${PROCESS_TRACE}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        ;;
  esac
        dumpError_STATUS=$1
        dumpError_MASAGE=$2
        dumpError_GLOBAL_PARAM=$3
        if [ ${dumpError_STATUS} -ne 0 ]
        then
                echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  >> ${DUMP_LOG} 2>&1
                echo ""  >> ${DUMP_LOG} 2>&1
                echo "${dumpError_MASAGE}" >> ${DUMP_LOG} 2>&1
                echo ""  >> ${DUMP_LOG} 2>&1
                echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  >> ${DUMP_LOG} 2>&1
                echo ""  >> ${DUMP_LOG} 2>&1
        fi

        return ${dumpError_STATUS}
}

executeCommand(){
##############################################################################################################
#  this function is an inner function
#  it gets one marameter
#       1) command to execute
#  it executes the command and return the value from the mysql
##############################################################################################################
  case $ORACLE_TRACE in
    T) set -x
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        PROCESS_TRACE="executeCommand:${PROCESS_TRACE}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        ;;
  esac

        export DB_COMMAND=$1
        PRINT_COMMAND=$2
        if [ "${PRINT_COMMAND}" == "PRINT_COMMAND" ]
         then
                echo "$DB_COMMAND"
        fi

        #/usr/bin/mysql --user=${MYSQL_USERNAME} --password=${MYSQL_PASSWORD}  -e "show databases;"

        /usr/bin/mysql --user=${MYSQL_USERNAME} --password=${MYSQL_PASSWORD}  -e "$DB_COMMAND"

        GLOBAL_ERROR_STATUS=$?

        return ${GLOBAL_ERROR_STATUS}
}


exitProcess(){
##############################################################################################################
#  exitProcess does the following:
#  1) if status 0 then print success massage
#  2) if status != 0 then print the error status and the main log
#  3) delete all temporary files and folders
#  4) exit with the $1 status
##############################################################################################################
  case $ORACLE_TRACE in
    T) set -x
        echo " " > /dev/null
        PROCESS_TRACE="exitProcess:${PROCESS_TRACE}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        echo                  >> ${MAIN_LOG}
        echo "Process Flow:"  >> ${MAIN_LOG}
        echo ${PROCESS_TRACE} >> ${MAIN_LOG}
        echo                  >> ${MAIN_LOG}
        ;;
  esac
        exitStatus=$1

  case $ORACLE_TRACE in
     P) echo
        echo "            $MAIN_LOG "
        echo
        kill %1
        ;;
  esac
  exitStatus=$1
  exitMessege=$2
  #checkError ${WORNING_STATUS} "WORNING - some failers - look in log"

  if [ ${WORNING_STATUS} -ne 0 ]
  then
        exitStatus=1000
  fi

        echo "##################################################################################">>          ${MAIN_LOG}
        case ${exitStatus} in
                0) echo " ${PROGRAM_FULL} ${THE_FUNCTION} ended successfully at `date`   |`date +%Y%m%d%H`  "
                   echo   " ${PROGRAM_FULL} ran with parameters: ${ALL_PARAMETERS} "
                   logFileName="${FINAL_LOG_DIR}/${PROGRAM_FULL}_${THE_FUNCTION}_`date +%d%m%Y`_$$.log"
                   cp ${MAIN_LOG} ${logFileName}
                   echo   " Operation Log: ${logFileName}"
                   case $ORACLE_TRACE in
                       T)  tarZip ${TMP_DIR} ${FINAL_LOG_DIR}
                           echo   " running in Trace mode:  zipped WorkDir: ${FINAL_LOG_DIR}/${TMP_DIR_NAME}" ;;
                   esac ;;
               1974) echo " " > ${MAIN_LOG};; # status  1974 means that want to exit with error status but with out message
                *) echo " ${PROGRAM_FULL} ${THE_FUNCTION} ended with error $1 `date`  | `date +%Y%m%d%H`      ">> ${MAIN_LOG}
                   echo "##################################################################################">> ${MAIN_LOG}
                   cat ${MAIN_LOG}
                   logFileName="${FINAL_LOG_DIR}/${PROGRAM_FULL}_${THE_FUNCTION}_`date +%d%m%Y`_$$.log"
                   cp ${MAIN_LOG} ${logFileName}
                   tarZip ${TMP_DIR} ${FINAL_LOG_DIR}
                   echo   " Operation Log : ${logFileName}"
                   echo   " zipped WorkDir: ${FINAL_LOG_DIR}/${TMP_DIR_NAME}"
                ;;
        esac
                #exit ${exitStatus}

                if [ -f $TMP_FILE ]
                  then
                        rm $TMP_FILE
                fi
                if [ -f $SQL_FILE ]
                  then
                        rm $SQL_FILE
                fi
                if [ -d $TMP_DIR ]
                  then
                        rm -rf $TMP_DIR
                fi

                echo
                exit ${exitStatus}
}

startSlave(){
########################################################################
#  this function starts a slave process in mysql replicated database
########################################################################
  executeCommand "START SLAVE;  "
}

isPrimary(){
########################################################################
#  this function checks if the database is a primary database
#  its an internal function
########################################################################
  case $ORACLE_TRACE in
    T) set -x
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        PROCESS_TRACE="isPrimary:${PROCESS_TRACE}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        ;;

  esac

        IS_PRIME=`executeCommand "select 1-count(*) from v\\$database where DATABASE_ROLE='PRIMARY'"`
        checkError ${IS_PRIME} "Database ${ORACLE_SID} Is not Primary Database"
        echo "datatabase '${ORACLE_SID}' in '`hostname`' is Primary database" >> ${MAIN_LOG}
}

isStandby(){
########################################################################
#  this function checks if the database is a standby database
#  its an internal function
########################################################################
  case $ORACLE_TRACE in
    T) set -x
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        PROCESS_TRACE="isStandby:${PROCESS_TRACE}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        ;;
  esac
        echo >> ${MAIN_LOG}
        echo "--------------------------------------"              >> ${MAIN_LOG}
        echo " checking if database is Standby DB   "              >> ${MAIN_LOG}
        echo "--------------------------------------"              >> ${MAIN_LOG}

        IS_STANDBY=`executeCommand "select 1-count(*) from v\\$database where DATABASE_ROLE='PHYSICAL STANDBY'"`
        checkError ${IS_STANDBY}  "Database ${ORACLE_SID} Is not Standby Database"
}


logError(){
##############################################################################################################
#  list Error get 3 parameters
#    1) status that it supose to check
#    2) error message
#    3) error list file
#  the procedure checks the parameter and if is diferent then 1 it write to File (parameter 3)
#  the message it gets as parameter 2
#  if status is not 0 then it changes WORNING_STATUS to 1
##############################################################################################################
  case $ORACLE_TRACE in
    T) set -x
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        PROCESS_TRACE="logError:${PROCESS_TRACE}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        ;;
  esac
        logError_STATUS=$1
        logError_MASAGE=$2
        #logError_FILE=$3
        logError_FILE=`setDefault ${MAIN_LOG} ${3}`



        if [ ${logError_STATUS} -ne 0 ]
        then
                WORNING_STATUS=1
                WORNING_MESSAGE=" with worning "
                echo "${logError_MASAGE}" >> ${logError_FILE} 2>&1
        fi

        return ${logError_STATUS}
}


printError(){
##############################################################################################################
#  check error get 2 parameters
#  1) status that it supose to check (if = 0 then it does nothing else it prints the error)
#  2) string to echo incase that the status != 0
##############################################################################################################

        if [ $1 -ne 0 ]
        then
                echo
                echo "#        $2"
                echo

                exitProcess $1
        fi

}


runRemotemySqlReplicator(){
########################################################################
#  this proedure gets two Parameters
#  1) remote machine
#  2) Parameters
#  it then runs mySqlReplicator in the remote machine with the parameters
########################################################################
  case $ORACLE_TRACE in
    T) set -x
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        PROCESS_TRACE="runRemotemySqlReplicator:${PROCESS_TRACE}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null ;;
  esac
        REMOTE_MACHINE=$1
        DG_PARAMETERS=$2
        ssh ${REMOTE_MACHINE} -n "${SCRIPT_DIR}/mySqlReplicator ${DG_PARAMETERS}" 2> ${ERROR_FILE}
        return $?
}


setDefault(){
########################################################################
# this function gets two Parameters if first one is null then it sets
# it to the secound one
########################################################################

        PARAMETER_1=$1
        PARAMETER_2=$2
        if [ ${PARAMETER_2} ]
        then
                echo ${PARAMETER_2}
          else
                echo ${PARAMETER_1}
        fi

}

setGeneralParam(){
##############################################################################################################
#  set list of parameters
##############################################################################################################
  case $ORACLE_TRACE in
   T) set -x
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        PROCESS_TRACE="setGeneralParam:${PROCESS_TRACE}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        ;;
  esac

        DATA_DIR_NAME=
        SCRIPT_BASE=`dirname $0`
        TMP_DIR=${SCRIPT_BASE}/tmp/mySqlReplicator$$
        TMP_DIR_NAME=mySqlReplicator$$
        TMP_FILE=${TMP_DIR}/tmp$$
        SQL_FILE=${TMP_DIR}/tmp$$.sql
        MAIN_LOG=${TMP_DIR}/mainLog$$.log
        DUMP_LOG=${TMP_DIR}/dumpLog$$.log
	NC_LOG=${TMP_DIR}/ncLog$$.log
        GLOBAL_DUMP_STATUS=0
        ERROR_FILE=${TMP_DIR}/errorFile$$.log
        ERROR_LOG=${TMP_DIR}/errorLog$$.log
        #export PATH=~/bin:${PATH}
        AWK=/usr/bin/awk
        WORNING_STATUS=0
        SCRIPT_DIR=${SCRIPT_BASE}/bin
        PATH=$PATH:${SCRIPT_DIR}
        FINAL_LOG_DIR=${SCRIPT_BASE}/logs
        mkdir -p ${FINAL_LOG_DIR}
        GLOBAL_ERROR_STATUS=0
        AWK=/usr/bin/awk
        alias tr=/usr/bin/tr
        alias awk=/usr/bin/awk
        MKNODE=/usr/bin/mkfifo 
        MKNODE_FLAG=
	STATUS_MYSQL_DOWN=3
}

setMySqlParam(){
##############################################################################################################
#  this is an inner function it has no interface to the outside world
#  get one parameter  ORACLE_SID
#  set parameters for specific database
#  we assume the set_sid is in the PATH
#  if DB is not in  $ORATAB it returns en error and exits
##############################################################################################################
  case $ORACLE_TRACE in
    T) set -x
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        PROCESS_TRACE="setOraInstParam:${PROCESS_TRACE}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        ;;
  esac

      #export MYSQL_HOST=`hostname -s`
      #export MYSQL_PORT=`grep port /etc/my.cnf|awk -F= '{print $NF}'|sed "s/ //g"`
      export MYSQL_USERNAME='snapshot'
      export MYSQL_PASSWORD='weather_surprise%'


}

tarZip(){
##############################################################################################################
# this function gets one or two parameters
# first one is file or directory to tar and zip
# secound parameter is destination
# if no destination specified then it uses one directory above the file/directory to tarZip
# function tar the directory and gzips the tar file.
# it generates a log of the process with same name as the tarzip file with ".log" extention
##############################################################################################################

        FILE_DIR_TO_TARZIP=$1
        DEST_DIRECTORY=$2

        if [ "${DEST_DIRECTORY}" = "" ]
        then
                DEST_DIRECTORY=`dirname ${FILE_DIR_TO_TARZIP}`
        fi

        SHORT_FILE_NAME=`basename ${FILE_DIR_TO_TARZIP}|awk -F"." '{print $1}'`
        TARZIP_FILE_NAME=${DEST_DIRECTORY}/${SHORT_FILE_NAME}.tar.gz
        TAR_LOG=${DEST_DIRECTORY}/${SHORT_FILE_NAME}.log

        IPIPE=pipe.$$
        export IPIPE

  ${MKNODE} ${IPIPE} ${MKNODE_FLAG}

        cat  $IPIPE|/bin/gzip -f > $TARZIP_FILE_NAME &

        tar -cvf $IPIPE ${FILE_DIR_TO_TARZIP} >> $TAR_LOG 2>&1

        /bin/rm $IPIPE
}

createSnapshot(){
#set -x
  SNAPSHOT_NAME=$1
  SNAPSHOT_SIZE=$2
  TO_MOUNT=$3
  SNAPSHOT_MOUNT_NAME=$4

  export MYSQL_LV=` lvdisplay |grep mysql|head -1 |awk '{print $NF}' `
  export RUN_DATE=`date +%Y%m%d%H`
  export SNAPSHOT_NAME="mysql-snap-${RUN_DATE}"
  export SNAPSHOT_SIZE=60G
  export SNAPSHOT_MOUNT_NAME=/mySqlReplicator$$
  export VG_DIR=/dev/mdata
  export DATA_DIR_NAME=prod

  RUNNING_HOST_NAME=`hostname -s`

  CHECK_SOURCE_SERVER=`echo ${SOURCE_SERVER}|awk -F'.' '{print $1}' `

  if [ ${RUNNING_HOST_NAME} != ${CHECK_SOURCE_SERVER} ]
    then
       checkError "running on ${RUNNING_HOST_NAME} while sourceServer param = ${SOURCE_SERVER}} "
  fi

  # check that there is only one volume
  MYSQL_VOLUME_COUNT=`lvdisplay |grep mysql|wc -l `
  if [ ${MYSQL_VOLUME_COUNT} -ne 1 ]
    then
        echoLog "below are the volumes matching mysql directory"
        echoLog "`vdisplay |grep mysql`"
        checkError ${MYSQL_VOLUME_COUNT} " there are more than 1 volumems that match logic of mysql volume... exiting"
  fi

  executeCommand "FLUSH TABLES WITH READ LOCK;  " >> ${MAIN_LOG}
  checkError $? "failed to flush the tables"
  executeCommand "FLUSH LOGS;" >> ${MAIN_LOG}
  checkError $? "failed to flush logs"


  echoLog "creating a snapshot for volume of mysql -  ${SNAPSHOT_NAME}"
  lvcreate -L${SNAPSHOT_SIZE} -s -n ${SNAPSHOT_NAME} ${MYSQL_LV}
  checkError $?  "failed to create snapshot"

  executeCommand "UNLOCK TABLES; " >> ${MAIN_LOG}
  checkError $? "failed to unlock the tables"

  echo
  echo "created snapshot ${SNAPSHOT_NAME}"
  echo

}


echoLog(){
###############################################################################
#  this function echos to the logfile ${MAIN_LOG}
############################################################################### i
  echo $1 
  echo    >> ${MAIN_LOG}
  echo "`date` - $1 " >> ${MAIN_LOG}
}

replicateDBFromSnap(){
###############################################################################
#  this function copies mySqlDatabase to another server
############################################################################### i

#set -x
  SOURCE_SERVER=$1
  DEST_SERVER=$2
  DEST_NC_PORT=$3
  SNAPSHOT_NAME="$4"
  COMPRESS=$5

  if [ "${COMPRESS}" == "COMPRESS" ]
  then
        checkPbzip2
  fi

  export MYSQL_LV=` lvdisplay |grep mysql|head -1 |awk '{print $NF}' `
  export RUN_DATE=`date +%Y%m%d%H`
  export SNAPSHOT_MOUNT_NAME=/mySqlReplicator$$
  export VG_DIR=/dev/mdata

  RUNNING_HOST_NAME=`hostname -s`
  CHECK_SOURCE_SERVER=`echo ${SOURCE_SERVER}|awk -F'.' '{print $1}' `

  if [ ${RUNNING_HOST_NAME} != ${CHECK_SOURCE_SERVER} ]
    then
       checkError 1 "running on ${RUNNING_HOST_NAME} while sourceServer param = ${SOURCE_SERVER}} "
  fi

  # check that there is only one volume
  MYSQL_VOLUME_COUNT=`lvdisplay |grep mysql||grep ${SNAPSHOT_NAME}|wc -l `
  if [ ${MYSQL_VOLUME_COUNT} -ne 1 ]
    then
        echoLog "below are the volumes matching mysql directory"
        echoLog "`vdisplay |grep mysql`"
        checkError ${MYSQL_VOLUME_COUNT} " there are more than 1 volumems that match logic of mysql volume... exiting"
  fi

  echoLog "creaging  mount dir and mounting the snapshot"
  mkdir ${SNAPSHOT_MOUNT_NAME}
  checkError $? "failed to create ${SNAPSHOT_MOUNT_NAME}"

  echoLog "mounting ${VG_DIR}/${SNAPSHOT_NAME} on ${SNAPSHOT_MOUNT_NAME}"
  mount -o nouuid ${VG_DIR}/${SNAPSHOT_NAME} ${SNAPSHOT_MOUNT_NAME}
  checkError $? "failed to mount ${VG_DIR}/${SNAPSHOT_NAME} on ${SNAPSHOT_MOUNT_NAME}"

  cd ${SNAPSHOT_MOUNT_NAME}

  echoLog "starting copy process using tar -> nc "
  echoLog "NC_LOG name is ${NC_LOG}"
  if [ "${COMPRESS}" == "COMPRESS" ]
    then
       tar cvf - ${DATA_DIR_NAME} | pbzip2 -p4 | nc ${DEST_SERVER} ${DEST_NC_PORT} > ${NC_LOG} 2>&1
    else
       tar cvf - ${DATA_DIR_NAME} | nc ${DEST_SERVER} ${DEST_NC_PORT} > ${NC_LOG} 2>&1
  fi

  checkError $? "failed to copy the snapshot to destination host"
  echoLog

}


 
replicateDB(){
###############################################################################
#  this function copies mySqlDatabase to another server 
############################################################################### i

#set -x 
  SOURCE_SERVER=$1
  DEST_SERVER=$2
  DEST_NC_PORT=$3
  COMPRESS=$4

  if [ "${COMPRESS}" == "COMPRESS" ]
  then
        checkPbzip2
  fi

  export MYSQL_LV=` lvdisplay |grep mysql|head -1 |awk '{print $NF}' `
  export RUN_DATE=`date +%Y%m%d%H`
  export SNAPSHOT_NAME="mysql-snap-${RUN_DATE}"  
  export SNAPSHOT_SIZE=60G  
  export SNAPSHOT_MOUNT_NAME=/mySqlReplicator$$
  export VG_DIR=/dev/mdata

  RUNNING_HOST_NAME=`hostname -s`
  CHECK_SOURCE_SERVER=`echo ${SOURCE_SERVER}|awk -F'.' '{print $1}' `

  if [ ${RUNNING_HOST_NAME} != ${CHECK_SOURCE_SERVER} ]
    then 
       checkError 1 "running on ${RUNNING_HOST_NAME} while sourceServer param = ${SOURCE_SERVER}} "
  fi 

  # check that there is only one volume 
  MYSQL_VOLUME_COUNT=`lvdisplay |grep mysql|wc -l `
  if [ ${MYSQL_VOLUME_COUNT} -ne 1 ]
    then
        echoLog "below are the volumes matching mysql directory"
        echoLog "`vdisplay |grep mysql`"
        checkError ${MYSQL_VOLUME_COUNT} " there are more than 1 volumems that match logic of mysql volume... exiting"
  fi

  executeCommand "FLUSH TABLES WITH READ LOCK;  " >> ${MAIN_LOG}
  checkError $? "failed to flush the tables"
  executeCommand "FLUSH LOGS;" >> ${MAIN_LOG}
  checkError $? "failed to flush logs"


  echoLog "creating a snapshot for volume of mysql -  ${SNAPSHOT_NAME}"
  lvcreate -L${SNAPSHOT_SIZE} -s -n ${SNAPSHOT_NAME} ${MYSQL_LV}
  checkError $?  "failed to create snapshot"

  executeCommand "UNLOCK TABLES; " >> ${MAIN_LOG}
 checkError $? "failed to unlock the tables"

  echoLog "creaging  mount dir and mounting the snapshot"
  mkdir ${SNAPSHOT_MOUNT_NAME}
  checkError $? "failed to create ${SNAPSHOT_MOUNT_NAME}"

  echoLog "mounting ${VG_DIR}/${SNAPSHOT_NAME} on ${SNAPSHOT_MOUNT_NAME}"
  mount -o nouuid ${VG_DIR}/${SNAPSHOT_NAME} ${SNAPSHOT_MOUNT_NAME}
  checkError $? "failed to mount ${VG_DIR}/SNAPSHOT_NAME on ${SNAPSHOT_MOUNT_NAME}"

  cd ${SNAPSHOT_MOUNT_NAME}
  
  echoLog "starting copy process using tar -> nc "
  echoLog "NC_LOG name is ${NC_LOG}"
  if [ "${COMPRESS}" == "COMPRESS" ]
    then
       tar cvf - ${DATA_DIR_NAME} | pbzip2 -p4 | nc ${DEST_SERVER} ${DEST_NC_PORT} > ${NC_LOG} 2>&1
    else
       tar cvf - ${DATA_DIR_NAME} | nc ${DEST_SERVER} ${DEST_NC_PORT} > ${NC_LOG} 2>&1
  fi	

  checkError $? "failed to copy the snapshot to destination host" 
  echoLog

}

ncSnapshot(){
###############################################################################
#  this function copies mySqlDatabase to another server 
###############################################################################

  SNAP_NAME=$1
  SNAP_MOUNT=$2
  SOURCE_SERVER=$3
  DEST_SERVER=$4
  DEST_NC_PORT=$5
  COMPRESS=`echo $6 | tr '[:lower:]' '[:upper:]'  ` 

  if [ "${COMPRESS}" == "COMPRESS" ]
  then
        checkPbzip2
  fi

  DATA_DIR_NAME=prod

  echoLog "check if vol is a snapshot "
  IS_SNAPSHOT=`lvdisplay -v ${SNAP_NAME} |grep "Snapshot chunk size"|wc -l `
  if [ ${IS_SNAPSHOT} -ne 1 ]
     then
       checkError 1 "${SNAP_NAME}  is not a snapshot"
  fi
  echoLog "  - OK "

  echoLog "check if snapshot contains a snap in name"
  SNAPSHOT_CONTAINS_SNAP_IN_NAME=`echo ${SNAP_NAME} | grep snap |wc -l `
  if [ ${SNAPSHOT_CONTAINS_SNAP_IN_NAME} -ne 1 ]
     then
       checkError 1 "${SNAP_NAME}  does not contain snap in the name"
  fi
  echoLog "  - OK "

  echoLog "check if mouted dir is the mount for the snap presented"
  IS_SNAP_MOUNTED=`mount|grep ^${SNAP_NAME} |grep ${SNAP_MOUNT}|wc -l `
  if [ ${IS_SNAP_MOUNTED} -ne 1 ]
     then
       checkError 1 "${SNAP_NAME} is not mounted on ${SNAP_MOUNT} "
  fi
  echoLog "  - OK "

  cd ${SNAP_MOUNT}

  echoLog "starting copy process using tar -> nc "
  echoLog "NC_LOG name is ${NC_LOG}"
  if [ "$COMPRESS" == "COMPRESS" ]
    then
       tar cvf - ${DATA_DIR_NAME} | pbzip2 -p4 | nc ${DEST_SERVER} ${DEST_NC_PORT} > ${NC_LOG} 2>&1
    else
       tar cvf - ${DATA_DIR_NAME} | nc ${DEST_SERVER} ${DEST_NC_PORT} > ${NC_LOG} 2>&1
  fi

  checkError $? "failed to copy the snapshot to destination host"
  echoLog

}

replicateDBDest(){
###############################################################################
# this function starts NC and after recieaving the files start the DB
###############################################################################

  DEST_SERVER=$1
  DEST_NC_PORT=$2
  DEST_DIR=$3
  COMPRESS=$4

  if [ "${COMPRESS}" == "COMPRESS" ]
  then
        checkPbzip2
  fi

  RELEY_LOG_INFO=${DEST_DIR}/${DATA_DIR_NAME}/relay-log.info
  RELEY_LOG_INFO_BACKUP=${DEST_DIR}/${DATA_DIR_NAME}/relay-log.info_mySqlReplicator_$$.backup

  echoLog "checking mysql is down before start of replication - it should be down !!!"
  /etc/init.d/mysql status
  if [ $? -ne ${STATUS_MYSQL_DOWN} ]
  then 
	checkError 1 "mysql is not down, please shutdown mysql before start to replicate"
  fi

  echoLog "check ${DEST_DIR} is empty "
  FILE_CNT=`ls -1 ${DEST_DIR} |wc -l `
  checkError ${FILE_CNT}  "${DEST_DIR} is not empty, please clean directory before start of replication"

 
  cd ${DEST_DIR}

  if [ "${COMPRESS}" == "COMPRESS" ]
  then
  	echoLog "starting listener on port ${DEST_NC_PORT}, compression is true"  
  	nc -l ${DEST_NC_PORT}  |pbzip2 -d  |tar xvf -
  else 
  	echoLog "starting listener on port ${DEST_NC_PORT}"  
  	nc -l ${DEST_NC_PORT} |tar xvf -  
  fi

  checkError  $? "failed to get data from source"
  echoLog " - copy complited OK "

  echoLog " backup relay-log.info ${RELEY_LOG_INFO} - see patchHistory for explination"
  cp ${RELEY_LOG_INFO} ${RELEY_LOG_INFO_BACKUP}
  checkError $? "failed to backup ${RELEY_LOG_INFO}, will not start mysql before that"

 
  echoLog "running chef-client"
  chef-client

  echoLog "starting mysql"
  /etc/init.d/mysql start
  checkError $? "failed to start mysql after data was copied"
  echoLog "starting mysql - OK "

  echoLog "check if perfona server overwrote  relay-log.info "
  RELEY_LOG_INFO_CKSUM=`cksum ${RELEY_LOG_INFO}|awk '{print $1}'`
  RELEY_LOG_INFO_BACKUP_CKSUM=`cksum ${RELEY_LOG_INFO_BACKUP}|awk '{print $1}'`

  if [ ${RELEY_LOG_INFO_CKSUM}  -ne ${RELEY_LOG_INFO_BACKUP_CKSUM} ]
  then
	echoLog "startup by percona changed ${RELEY_LOG_INFO}, will put backup of file back and restart mysql"
	/etc/init.d/mysql stop
	cp ${RELEY_LOG_INFO_BACKUP} ${RELEY_LOG_INFO}
	checkError $? "failed to restore ${RELEY_LOG_INFO} with ${RELEY_LOG_INFO_BACKUP} "
	/etc/init.d/mysql start
  	checkError $? "failed to start mysql after data was copied"
  	echoLog "starting mysql - OK "
  fi

  sleep 5
  echoLog "starting slave process"
  executeCommand "start slave;"
  echoLog "starting slave process - OK "

 echo " after all is done please run  -  mycli watch stat "

}

deleteSnapshot(){ 
###############################################################################
#
###############################################################################

  SNAP_TO_DELETE=$1 
  DIR_TO_UMOUNT=$2

  echoLog "check if snap to delete is a snapshot "
  IS_SNAPSHOT=`lvdisplay -v ${SNAP_TO_DELETE} |grep "Snapshot chunk size"|wc -l `
  if [ ${IS_SNAPSHOT} -ne 1 ]
     then
       checkError 1 "${SNAP_TO_DELETE}  is not a snapshot" 
  fi
  echoLog "  - OK "

  echoLog "check if snap to delete contains a snap in name"
  SNAP_TO_DELETE_CONTAINS_SNAP_IN_NAME=`echo ${SNAP_TO_DELETE} | grep snap |wc -l `
  if [ ${SNAP_TO_DELETE_CONTAINS_SNAP_IN_NAME} -ne 1 ]
     then
       checkError 1 "${SNAP_TO_DELETE}  does not contain snap in the name" 
  fi
  echoLog "  - OK "

  echoLog "check if mouted dir is the mount for the snap presented"
  IS_SNAP_MOUNTED=`mount|grep ^${SNAP_TO_DELETE} |grep ${DIR_TO_UMOUNT}|wc -l `
  if [ ${IS_SNAP_MOUNTED} -ne 1 ]
     then
       checkError 1 "${SNAP_TO_DELETE} is not mounted on ${DIR_TO_UMOUNT} "
  fi
  echoLog "  - OK "

  echoLog "about to umount ${DIR_TO_UMOUNT}"
  umount ${DIR_TO_UMOUNT}
  checkError $? "failed to umount ${DIR_TO_UMOUNT}"

  echoLog "about to rmdir ${DIR_TO_UMOUNT}"
  rmdir ${DIR_TO_UMOUNT}
  checkError $? "failed to rmdir ${DIR_TO_UMOUNT}"

  echoLog "about to delete snapshot ${SNAP_TO_DELETE}"
  lvremove ${SNAP_TO_DELETE}
  checkError $? "failed to delete snapshot ${SNAP_TO_DELETE}"


}

DISPLAY_MESSAGE(){
###############################################################################
#  display message get one parameter
#  if a pre prepaired message then print message
#  else print the parameter
###############################################################################
  case $ORACLE_TRACE in
    T) set -x
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        PROCESS_TRACE="DISPLAY_MESSAGE:${PROCESS_TRACE}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        ;;
  esac
  case $1 in
    "usage_msg" ) echo ""
                  echo "usage: mySqlReplicator [ replicateDB          [ sourceHost ] [ targetHost ]  [ portForNC ]  [ compress ]] "
                  echo "                       [replicateDbFromSnap   [ sourceHost ] [ targetHost ]  [ portForNC ] [ snapshotName ] [ compress ]  "
                  echo "                       [ replicateDBDest      [ targetHost ] [ portForNC ]   [ destDir ] [ compress ]"
                  echo "                       [ ncSnapshot           [ snapName ]   [ mountName ]   [ sourceHost ] [ targetHost ]  [ portForNC ]  [ usePV ] ]"
                  echo "                       [ deleteSnapshot       [ snapshotName ] [ snapshotMount ] "
                  echo "                       [ createSnapshot ]"
                  echo "                       [ startMysql ] "
                  echo "                       [ startSlave ] "
                  echo "                       [ version ] "
                  echo "                       [ aboutFunctions ] "
                  echo
                      ;;
        "mySqlReplicator")
                      echo ""
                      echo "  mySqlReplicator version 1.14"
                      echo "  Last update date: 28.05.2016"
                      echo "    script was writen by "
                      echo "         Yaron Amir"
                      echo ""
                      ;;
        * )
                              echo
                                      echo "$1 "
                              echo
                                          ;;
  esac

}



######################################################################################################
# Main program
######################################################################################################
  case $ORACLE_TRACE in
    T) set -x
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        PROCESS_TRACE="main:${PROCESS_TRACE}"
        echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" > /dev/null
        ;;
  esac

  PROGRAM_FULL=`basename $0 `
  FULL_SCRIPT_NAME=$0
  if [ $# -lt 1 ]
  then
    DISPLAY_MESSAGE "usage_msg"
    exit 1974
  fi

  setGeneralParam

  mkdir -p $TMP_DIR
  touch ${ERROR_FILE}
  touch ${DUMP_LOG}
  case $ORACLE_TRACE in
     P) echo;echo "            $MAIN_LOG ";echo
        touch $MAIN_LOG
        tail -100f $MAIN_LOG&
        ;;
  esac
echo "#######################################################################"   > ${MAIN_LOG}
echo "#                 mySqlReplicator - $1                                       "  >> ${MAIN_LOG}
echo "#             started at `date`                                "  >> ${MAIN_LOG}
echo "#######################################################################">> ${MAIN_LOG}
echo "mySqlReplicator parameters: $@                                               ">> ${MAIN_LOG}
echo "running Machine     : `hostname`                                       ">> ${MAIN_LOG}


opt=`echo $1 | tr '[:lower:]' '[:upper:]'`
ALL_PARAMETERS=$@

THE_FUNCTION=$1

case $opt in
   HELP|? )
            DISPLAY_MESSAGE "usage_msg"
            exitProcess 1974
            ;;
  ABOUTFUNCTIONS )
            aboutFunctions ;;
     REPLICATEDBFROMSNAP )
        checkInput $# 4 "usage: mySqlReplicator [ replicateDbFromSnap          [ sourceHost ] [ targetHost ]  [ portForNC ] [ snapshotName ] [ compress ]  "
        setMySqlParam 
        COMPRESS=`echo $5 | tr '[:lower:]' '[:upper:]'`
        replicateDBFromSnap $2 $3 $4 "$5" $COMPRESS
        ;;
     REPLICATEDB )
        checkInput $# 4 "usage: mySqlReplicator [ replicateDB          [ sourceHost ] [ targetHost ]  [ portForNC ]  [ compress ]  "
        setMySqlParam 
        COMPRESS=`echo $5 | tr '[:lower:]' '[:upper:]'`
        replicateDB $2 $3 $4 $COMPRESS
        ;;
     NCSNAPSHOT )
        checkInput $# 4 "usage: mySqlReplicator [ ncSnapshot           [ snapName ] [ mountName ]  [ sourceHost ] [ targetHost ]  [ portForNC ]  [ compress ] "
        setMySqlParam 
        COMPRESS=`echo $6 | tr '[:lower:]' '[:upper:]'`
        ncSnapshot $2 $3 $4 $5 ${COMPRESS}
        ;;
     REPLICATEDBDEST )
        checkInput $# 3 "usage: mySqlReplicator [ replicateDBDest      [ targetHost ] [ portForNC ] [ destDir ] [ compress ( default null ) ] "
        setMySqlParam 
	COMPRESS=`echo $5 | tr '[:lower:]' '[:upper:]'`
        replicateDBDest $2 $3 $4 ${COMPRESS}
        ;;
     CREATESNAPSHOT)
            setMySqlParam
            createSnapshot
            ;;
    STARTMYSQL )
        /etc/init.d/mysql start
        ;;
    STARTSLAVE )
        setMySqlParam
        startSlave
        ;;
    DELETESNAPSHOT )
        checkInput $# 3 "usage: mySqlReplicator [ deleteSnapshot   [ snapshotName ] [ snapshotMount ]"
        deleteSnapshot $2 $3 
        ;;
    VERSION )
        DISPLAY_MESSAGE "mySqlReplicator"
        exitProcess 1974 ;;
          *)
            DISPLAY_MESSAGE "usage_msg"
            exitProcess 1974
            ;;
esac

exitProcess 0

patchHistory(){
######################################################################################################
#   change tracking
#  1.00 - 08.09.2013 - initial script
#  1.01 - 08.09.2013 - added the following procedures
# . . . . . . . . . .- replicateDB 
# . . . . . . . . . .- replicateDBDest
# . . . . . . . . . .- deleteSnapshot
#  1.02 - 08.09.2013 - added NC_LOG
#  1.03 - 09.10.2013 - added usePV
# . . . . . . . . . .- changed final_log_dir to ${SCRIPT_BASE}/logs
#  1.04 - 12.10.2013 - added ncSnapshot
#  1.05 - 13.10.2013 - added create snapshot   ########## not working yet, in writing progress !!
#  1.06 - 12.10.2013 - added startMysql function
# . . . . . . . . . .- added startSlave function
#  1.07 - 19.05.2014 - fixed a check in replicateDBDest
# . . . . . . . . . .- added a check that mysql is down before start replicate
# . . . . . . . . . .- due to diferences between perfona and comunity, percona overwrite relay_log.info 
# . . . . . . . . . .- and comunity, cant handle it and fails, as we dont know what is the origen of the
# . . . . . . . . . .- database (percona/comunity) we added a workaround that backs up the file and 
# . . . . . . . . . .- restores is after first startup.  all done in replicateDBDest
#  1.08 - 20.05.2014 - fixed a misstype in ackup of relay-log.info
#  1.09 - 22.05.2014 - added sleep 5 seconds before start slave. fixed cksum of relay-log.info (had a misstype)
#  1.10 - 01.06.2014 - removed pv and added compression option using pbzip2  added checkPbzip2
#  1.11 - 01.06.2014 - fixed runninbg on check to user hostname -s 
#  1.12 - 14.04.2015 - added flag of mysql dead to check status    
#  1.13 - 04.05.2017 - may the 4'rth be with you !!!!!!!!!!
# . . . . . . . . . .- added ability to replicate using existing snapshot
#  1.14 - 28.05.2017 - added chef-client before start mysql databse in replicateDBDest
######################################################################################################
   echo  > /dev/null
}

