#!/bin/bash

TOP=$(cd `dirname $0`; pwd -P)

if [ $# -ne 2 ]; then
  echo -e "\nNeed these args -"
  echo -e "\n1. Fullpath of SPARK_HOME"
  echo -e "\n2. Foreground (fg) or Background (bg)"
  echo ; exit 1
fi

if [ -d $TOP/spark-jobserver ]; then
  ( cd $TOP/spark-jobserver ; git pull )
else
  git clone https://github.com/spark-jobserver/spark-jobserver $TOP/spark-jobserver
fi

( cd $TOP/spark-jobserver ; sbt assembly )

INSTALL_DIR=$TOP/try ; mkdir -p $INSTALL_DIR
/bin/cp -p $TOP/spark-jobserver/bin/server_start.sh $TOP/try
/bin/cp -p $TOP/spark-jobserver/bin/setenv.sh $TOP/try
/bin/cp -p $TOP/spark-jobserver/config/local.conf.template $TOP/try/local.conf
/bin/cp -p $TOP/spark-jobserver/config/local.sh.template $TOP/try/settings.sh
/bin/cp -p `ls $TOP/spark-jobserver/target/scala-2.1?/root-assembly-0.7.0-SNAPSHOT.jar` $TOP/try/spark-job-server.jar 
/bin/cp -p $TOP/spark-jobserver/job-server/config/log4j-server.properties $TOP/try

echo -e "\n#-------------------------------------------\n" >> $INSTALL_DIR/settings.sh
echo "INSTALL_DIR=$INSTALL_DIR" >> $INSTALL_DIR/settings.sh
echo "LOG_DIR=$INSTALL_DIR/logs" >> $INSTALL_DIR/settings.sh
echo "SPARK_HOME=$1" >> $INSTALL_DIR/settings.sh
echo "SPARK_CONF_DIR=$1/conf" >> $INSTALL_DIR/settings.sh

for port in `seq 8090 8099`; do
  nc -z localhost $port >/dev/null 2>&1
  [ $? -ne 0 ] && REST_PORT=$port && break
done

sed "s|port = 8090|port = $REST_PORT|" $INSTALL_DIR/local.conf >| $INSTALL_DIR/new_local.conf
/bin/mv $INSTALL_DIR/new_local.conf $INSTALL_DIR/local.conf

for port in `seq 9990 9999`; do
  nc -z localhost $port >/dev/null 2>&1
  [ $? -ne 0 ] && JMX_PORT=$port && break
done

sed "s|JMX_PORT=9999|JMX_PORT=$JMX_PORT|" $INSTALL_DIR/setenv.sh >| $INSTALL_DIR/new_setenv.sh
/bin/mv $INSTALL_DIR/new_setenv.sh $INSTALL_DIR/setenv.sh

cmd=$TOP/try/server_start.sh
[ "$2" == "fg" ] && cmd="JOBSERVER_FG=1 $cmd"
eval $cmd

