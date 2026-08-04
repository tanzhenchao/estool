# Elasticsearch命令行工具

# 1 安装方法
~~~
# cp ~/scripts/esTools.sh /usr/local/bin/estool
# chmod +x /usr/local/bin/estool
# vim /usr/local/bin/estool
~~~
修改如下参数，根据你的ES服务器实际填写即可，
~~~
esUser="elastic"
esPasswd="elasticpwd"
esHost="http://eslogsys.cmdschool.org:9200"
esLog="/var/log/esTools.log"
~~~
需要注意的是，脚本只查找命名规则为“主题-日期”（“postfix-2015.10.01”）的索引，匹配正则表达式如下，
~~~
# echo "postfix-2015.10.01" | grep -E '^[a-zA-Z0-9_-]+-[0-9]{4}\.[0-9]{2}\.[0-9]{2}$'
~~~
如果你有其他需求，请自行修改代码的正则表达式。
# 2 使用方法
## 2.1 获取帮助
~~~
# estool
Usage: /usr/local/bin/estool {expired-rm|topic-rm|shrink-shard}
~~~
## 2.2 删除超过360天的索引
### 2.2.1 命令帮助
~~~
# estool expired-rm
Usage: /usr/local/bin/estool expired-rm <retention days>}
~~~
### 2.2.2 命令范例
~~~
# estool expired-rm 360
~~~
## 2.3 收缩索引分片
### 2.3.1 命令帮助
~~~
# estool topic-rm
Usage: /usr/local/bin/estool topic-rm <topic name> <retention days>}
~~~
实现原理，请参阅，https://www.cmdschool.org/archives/30945
### 2.3.2 命令范例
~~~
# estool shrink-shard 180
~~~
## 2.4 删除超过60天包含某主题关键字的索引
### 2.4.1 命令帮助
~~~
# estool shrink-shard
Usage: /usr/local/bin/estool shrink-shard <retention days>}
~~~
### 2.4.2 命令范例
~~~
# estool topic-rm guardicore 60
~~~
# 3. 计划任务执行
~~~
# crontab -e
0 10 * * * /usr/local/bin/estool expired-rm 360
10 10 * * * /usr/local/bin/estool shrink-shard 180
20 10 * * * /usr/local/bin/estool topic-rm guardicore 60
~~~
