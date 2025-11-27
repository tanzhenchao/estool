# estools
Elasticsearch命令行工具

<h1>1 安装方法</h1>
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
<h1>2 使用方法</h1>
<h2>2.1 获取帮助</h2>
<pre>
estool
Usage: /usr/local/bin/estool {expired-rm|topic-rm|shrink-shard}
</pre>
<h2>2.2 删除超过360天的索引</h2>
<h3>2.2.1 命令帮助</h3>
<pre>
estool expired-rm
Usage: /usr/local/bin/estool expired-rm &lt;retention days&gt;
</pre>
<h3>2.2.2 命令范例</h3>
<pre>
estool expired-rm 360
</pre>
<h2>2.3 收缩索引分片</h2>
<h3>2.3.1 命令帮助</h3>
<pre>
estool topic-rm
Usage: /usr/local/bin/estool shrink-shard &lt;retention days&gt;
</pre>
<h3>2.3.2 命令范例</h3>
<pre>
estool shrink-shard 180
</pre>
<h2>2.4 删除包含某主题关键字的超过60的索引</h2>
<h3>2.4.1 命令帮助</h3>
<pre>
estool shrink-shard
Usage: /usr/local/bin/estool shrink-shard &lt;topic name&gt; &lt;retention days&gt;
</pre>
<h3>2.4.2 命令范例</h3>
<pre>
estool topic-rm guardicore 60
</pre>
<h1>3. 计划任务执行</h1>
<pre>
crontab -e
0 10 * * * /usr/local/bin/estool expired-rm 360
10 10 * * * /usr/local/bin/estool shrink-shard 180
20 10 * * * /usr/local/bin/estool topic-rm guardicore 60
</pre>
