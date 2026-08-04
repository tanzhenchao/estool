# Elasticsearch命令行工具

# 1 安装方法
<pre>
cp ~/scripts/esTools.sh /usr/local/bin/estool
chmod +x /usr/local/bin/estool
vim /usr/local/bin/estool
</pre>
修改如下参数，根据你的ES服务器实际填写即可，
<pre>
esUser="elastic"
esPasswd="elasticpwd"
esHost="http://eslogsys.cmdschool.org:9200"
esLog="/var/log/esTools.log"
</pre>
需要注意的是，脚本只查找命名规则为“主题-日期”（“postfix-2015.10.01”）的索引，匹配正则表达式如下，
<pre>
echo "postfix-2015.10.01" | grep -E '^[a-zA-Z0-9_-]+-[0-9]{4}\.[0-9]{2}\.[0-9]{2}$'
</pre>
如果你有其他需求，请自行修改代码的正则表达式。
# 2 使用方法
## 2.1 获取帮助
<pre>
estool
Usage: /usr/local/bin/estool {expired-rm|topic-rm|shrink-shard}
</pre>
## 2.2 删除超过360天的索引
### 2.2.1 命令帮助
<pre>
estool expired-rm
Usage: /usr/local/bin/estool expired-rm &lt;retention days&gt;
</pre>
### 2.2.2 命令范例
<pre>
estool expired-rm 360
</pre>
## 2.3 收缩索引分片
### 2.3.1 命令帮助
<pre>
estool topic-rm
Usage: /usr/local/bin/estool shrink-shard &lt;retention days&gt;
</pre>
实现原理，请参阅，https://www.cmdschool.org/archives/30945
### 2.3.2 命令范例
<pre>
estool shrink-shard 180
</pre>
## 2.4 删除超过60天包含某主题关键字的索引
### 2.4.1 命令帮助
<pre>
estool shrink-shard
Usage: /usr/local/bin/estool shrink-shard &lt;topic name&gt; &lt;retention days&gt;
</pre>
### 2.4.2 命令范例
<pre>
estool topic-rm guardicore 60
</pre>
# 3. 计划任务执行
<pre>
crontab -e
0 10 * * * /usr/local/bin/estool expired-rm 360
10 10 * * * /usr/local/bin/estool shrink-shard 180
20 10 * * * /usr/local/bin/estool topic-rm guardicore 60
</pre>
