#!bin/bash

# The following script consults with the target elasticsearch and
# checks for indices which are older than a stipulated time.
# Configure the following variables

elasticsearch_host="http://localhost:9200"
index_prefix="logstash-"
expiry_threshold_weeks=108

echo Curator execution started ...

index_dates=$(curl -XGET "${elasticsearch_host}/_cat/indices/${index_prefix}*" | \
              grep "${index_prefix}.*" | \
              awk '{split($3, a, "\-"); print a[2]}')

echofor i in ${index_dates}
do
  curr_index_date=$(date -j -f "%Y.%m.%d %H:%M:%S" "$i 00:00:00" +%s)
  if [ ${curr_index_date} -lt $(date -v-${expiry_threshold_weeks}w +%s) ]; then
    echo "Deleting ${index_prefix}$i ... "
    curl -s -XDELETE "${elasticsearch_host}/${index_prefix}$i"
    echo
  fi
done

echo Curator execution complete.