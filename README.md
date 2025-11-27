# estools
Elasticsearch命令行工具

1. 安装方法
~~~
cp ~/scripts/esTools.sh /usr/local/bin/estool
chmod +x /usr/local/bin/estool
~~~
3. 使用方法
3.1 获取帮助
~~~
estool
Usage: /usr/local/bin/estool {expired-rm|topic-rm|shrink-shard}
~~~
3.2 删除超过360天的索引
3.1.2 命令帮助
~~~
estool expired-rm
Usage: /usr/local/bin/estool expired-rm <retention days>}
~~~
3.1.2 命令范例
~~~
estool expired-rm 360
~~~
3.3 收缩索引分片
3.3.1 命令帮助
~~~
estool topic-rm
Usage: /usr/local/bin/estool topic-rm <topic name> <retention days>}
~~~
3.3.2 命令范例
~~~
estool shrink-shard 180
~~~
3.4 删除包含某主题关键字的超过60的索引
3.4.1 命令帮助
~~~
estool shrink-shard
Usage: /usr/local/bin/estool shrink-shard <retention days>}
~~~
3.4.2 命令范例
~~~
estool topic-rm guardicore 60
~~~
