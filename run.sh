#!/bin/bash

TOP=$(cd `dirname $0`; pwd -P)

if [ $# -ne 2 ]; then
  echo -e "\nNeed these args -"
  echo -e "\n1. Fullpath of SPARK_HOME"
  echo -e "\n2. Foreground (fg) or Background (bg)"
  echo ; exit 1
fi

[ -d $TOP/spark-jobserver ] || git clone https://github.com/spark-jobserver/spark-jobserver
[ -d $TOP/spark-jobserver/target ] || ( cd $TOPspark-jobserver ; sbt assembly )

mkdir -p try
/bin/cp -p $TOP/spark-jobserver/bin/server_start.sh $TOP/try
/bin/cp -p $TOP/spark-jobserver/bin/setenv.sh $TOP/try
/bin/cp -p $TOP/spark-jobserver/config/local.conf.template $TOP/try/local.conf
/bin/cp -p $TOP/spark-jobserver/config/local.sh.template $TOP/try/settings.sh
/bin/cp -p `ls $TOP/spark-jobserver/target/scala-2.1?/root-assembly-0.7.0-SNAPSHOT.jar` $TOP/try/spark-job-server.jar 
/bin/cp -p $TOP/spark-jobserver/job-server/config/log4j-server.properties $TOP/try

echo "#----------------------------" >> $TOP/try/settings.sh
echo "SPARK_HOME=$1" >> $TOP/try/settings.sh
echo "SPARK_CONF_DIR=$1/conf" >> $TOP/try/settings.sh

cmd=$TOP/try/server_start.sh
[ "$2" == "fg" ] && cmd="JOBSERVER_FG=1 $cmd"
eval $cmd

