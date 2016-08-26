#!/bin/bash

if [ $# -ne 2 ]; then
  echo -e "\nNeed these args -"
  echo -e "\n1. Fullpath of SPARK_HOME"
  echo -e "\n2. Foreground (fg) or Background (bg)"
  echo ; exit 1
fi

[ -d spark-jobserver ] || git clone https://github.com/spark-jobserver/spark-jobserver

if [ ! -d spark-jobserver/target ]; then
  cd spark-jobserver ; sbt assembly
fi

mkdir -p try

/bin/cp -p spark-jobserver/bin/server_start.sh try
/bin/cp -p spark-jobserver/bin/setenv.sh try
/bin/cp -p spark-jobserver/config/local.conf.template try/local.conf
/bin/cp -p spark-jobserver/config/local.sh.template try/settings.sh
/bin/cp -p `ls spark-jobserver/target/scala-2.1?/root-assembly-0.7.0-SNAPSHOT.jar` try/spark-job-server.jar 
/bin/cp -p spark-jobserver/job-server/config/log4j-server.properties try

echo "#----------------------------" >> try/settings.sh
echo "SPARK_HOME=$1" >> try/settings.sh
echo "SPARK_CONF_DIR=$1/conf" >> try/settings.sh

cmd=try/server_start.sh

[ "$2" == "fg" ] && cmd="JOBSERVER_FG=1 $cmd"

eval $cmd

