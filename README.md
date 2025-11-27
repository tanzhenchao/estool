# estools
Elasticsearch命令行工具

# 删除超过360天的索引
bash ~/scripts/esTools-dev.sh expired-rm 360

# 收缩索引分片
bash ~/scripts/esTools-dev.sh shrink-shard 180

# 删除包含某主题关键字的超过60的索引
bash ~/scripts/esTools-dev.sh topic-rm guardicore 60
