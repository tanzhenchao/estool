#!/bin/bash

# Elasticsearch 配置
esUser="elastic"
esPasswd="elasticpwd"
esHost="http://eslogsys.cmdschool.org:9200"
esLog="/var/log/esTools.log"

getIndices() {
    #############################################
    # 获取所有命名规则"xxx-2015.xx.xx"的索引
    #############################################

    local indices=$(curl -u "$esUser:$esPasswd" -s "$esHost/_cat/indices?h=index" | grep -E '^[a-zA-Z0-9_-]+-[0-9]{4}\.[0-9]{2}\.[0-9]{2}$')
    for index in $indices; do
	    echo "$index"
    done
}

getExpiredIndices() {
    #####################
    # 获取多少天前的索引
    #####################

    local retentionDays=$1

    if [[ -z "$retentionDays" ]]; then
        echo "Error: Retention days cannot be empty."
        return 1
    fi

    if ! [[ "$retentionDays" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Please enter a valid positive integer as the retention days."
        return 1
    fi

    local currentDate=$(date +%Y.%m.%d)
    local cutoffDate=$(date -d "$retentionDays days ago" +%Y.%m.%d)

    for index in $(getIndices); do
        local indexDate=$(echo $index | awk -F '-' '{print $NF}')

        if [[ "$indexDate" > "$cutoffDate" ]]; then
            continue
        fi
	echo "$index"
    done
}

removeAllExpiredIndex() {
    ########################
    # 删除多少天前的过期索引
    ########################

    local retentionDays=$1

    if [[ -z "$retentionDays" ]]; then
        echo "Error: Retention days cannot be empty."
        return 1
    fi

    if ! [[ "$retentionDays" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Please enter a valid positive integer as the retention days."
        return 1
    fi

    for index in $(getExpiredIndices "$retentionDays"); do
        local response=$(curl -u "$esUser:$esPasswd" -X DELETE -s "$esHost/$index")

        if [[ $response == *"acknowledged"* ]]; then
            echo "$(date +%Y-%m-%d\ %H:%M:%S) - Successfully deleted index: $index" | tee -a "$esLog"
        else
            echo "$(date +%Y-%m-%d\ %H:%M:%S) - Failed to delete index: $response" | tee -a "$esLog"
        fi
    done
}

getIndexNumberOfReplicas() {
    ##################
    # 获取副本数量设置
    ##################

    local indexName=$1
    local response=$(
        curl -u "$esUser:$esPasswd" -X GET -s "$esHost/$indexName/_settings" |
	       	jq ".\"$indexName\".settings.index.number_of_replicas" |
	       	sed 's/"//g'
    )
    echo "$response"
}

reduceAllExpiredIndexShards() {
    ########################
    # 收缩多少天前的索引副本
    ########################

    local retentionDays=$1

    if [[ -z "$retentionDays" ]]; then
        echo "Error: Retention days cannot be empty."
        return 1
    fi

    if ! [[ "$retentionDays" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Please enter a valid positive integer as the retention days."
        return 1
    fi

    for index in $(getExpiredIndices "$retentionDays"); do
	logStat=$(grep "$index" "$esLog" | grep "Successfully shard reduction" | wc -l)
	if [ $logStat != 0 ]; then
		#echo "$(date +%Y-%m-%d\ %H:%M:%S) - Skipping shared reduction: $index"
		continue
	fi
	local indexStat=$(getIndexNumberOfReplicas "$index")
	if [ $indexStat == 0 ]; then
		#echo "$(date +%Y-%m-%d\ %H:%M:%S) - Skipping shared reduction: $index"
		continue
	fi

        local response=$(curl -u "$esUser:$esPasswd" -X PUT -s "$esHost/$index/_settings" -H 'Content-Type: application/json' -d '{
          "settings": {
           "index": {
            "number_of_replicas": 0
           }
          }
        }')
        if [[ $response == *"acknowledged"* ]]; then
            echo "$(date +%Y-%m-%d\ %H:%M:%S) - Successfully shard reduction: $index" | tee -a "$esLog"
        else
            echo "$(date +%Y-%m-%d\ %H:%M:%S) - Failed to shared reduction: $response" | tee -a "$esLog"
        fi
    done
}

removeTopicExpiredIndex() {
    ########################
    # 删除多少天前的过期某主题索引
    ########################

    local topicName="$1"
    local retentionDays=$2

    if [[ -z "$topicName" ]]; then
        echo "Error: Retention days cannot be empty."
        return 1
    fi

    if [[ -z "$retentionDays" ]]; then
        echo "Error: Retention days cannot be empty."
        return 1
    fi

    if ! [[ "$retentionDays" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Please enter a valid positive integer as the retention days."
        return 1
    fi

    for index in $(getExpiredIndices "$retentionDays" | grep "$topicName"); do
        local response=$(curl -u "$esUser:$esPasswd" -X DELETE -s "$esHost/$index")

        if [[ $response == *"acknowledged"* ]]; then
            echo "$(date +%Y-%m-%d\ %H:%M:%S) - Successfully deleted index: $index" | tee -a "$esLog"
        else
            echo "$(date +%Y-%m-%d\ %H:%M:%S) - Failed to delete index: $response" | tee -a "$esLog"
        fi
    done
}

case "$1" in
        expired-rm)
                if [[ -z "$2" ]]; then
                    echo "Usage: $0 expired-rm <retention days>}"
                    exit 1
                fi
                removeAllExpiredIndex "$2"
                ;;
        topic-rm)
                if [[ -z "$2" || -z "$3" ]]; then
                    echo "Usage: $0 topic-rm <topic name> <retention days>}"
                    exit 1
                fi
                removeTopicExpiredIndex "$2" $3
                ;;
        shrink-shard)
                if [[ -z "$2" ]]; then
                    echo "Usage: $0 shrink-shard <retention days>}"
                    exit 1
                fi
                reduceAllExpiredIndexShards "$2"
                ;;
        *)
                echo "Usage: $0 {expired-rm|topic-rm|shrink-shard}"
                ;;
esac
exit 0
