#!/bin/bash

batchid=`cat /home/acadgild/project/logs/current-batch.txt`
LOGFILE=/home/acadgild/project/logs/log_batch_$batchid
VALIDDIR=/home/acadgild/project/processed_dir/valid/batch_$batchid
INVALIDDIR=/home/acadgild/project/processed_dir/invalid/batch_$batchid

echo "Running script for data enrichment and filtering..." >> $LOGFILE

spark-submit --class DataEnrichment \
--master local[2] \
--jars /usr/local/hive/lib/hive-hbase-handler-2.1.1.jar,/usr/local/hive/lib/hbase-client-1.1.1.jar,/usr/local/hive/lib/hbase-common-1.1.1.jar,/usr/local/hive/lib/hbase-hadoop-compat-1.1.1.jar,/usr/local/hive/lib/hbase-server-1.1.1.jar,/usr/local/hive/lib/hbase-protocol-1.1.1.jar,/usr/local/hive/lib/zookeeper-3.4.6.jar,/usr/local/hive/lib/guava-14.0.1.jar,/usr/local/hive/lib/htrace-core-3.1.0-incubating.jar \
/home/acadgild/project/scripts/MusicDataAnalysis/target/scala-2.11/musicdataanalysis_2.11-1.0.jar $batchid

if [ ! -d "$VALIDDIR" ]
then
mkdir -p "$VALIDDIR"
fi

if [ ! -d "$INVALIDDIR" ]
then
mkdir -p "$INVALIDDIR"
fi

echo "Copying valid and invalid records in local file system..." >> $LOGFILE

hadoop fs -get /user/hive/warehouse/project.db/enriched_data/batchid=$batchid/status=pass/* $VALIDDIR
hadoop fs -get /user/hive/warehouse/project.db/enriched_data/batchid=$batchid/status=fail/* $INVALIDDIR

echo "Deleting older valid and invalid records from local file system..." >> $LOGFILE

find /home/acadgild/project/processed_dir/ -mtime +7 -exec rm {} \;