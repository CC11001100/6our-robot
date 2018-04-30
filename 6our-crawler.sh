#! /bin/bash

######################################################
#
#
#
#  树洞网赞数抓取
#
#
######################################################

# env
cd `dirname $0`
source utils.sh

# 初始化线程数控制，使用10个线程并发抓取以免把树洞网站打死
init_thread 250 10

# 初始化业务相关变量
url="http://www.6our.com/qiushi?&p="
total_page_num=`curl_ "${url}1" | grep -oE "<a href='/qiushi\?\&p=2480' >最后一页</a>" | grep -oE "[0-9]+"`
log "total_page_num $total_page_num"

# 开始抓取列表
for page_num in `seq 1 $total_page_num`;
do
	read -u250
	{
		cur_page_url="${url}${page_num}"
		log "url ${cur_page_url} begin"
		curl_ $cur_page_url | grep -oE "id=\"yes-[0-9]+\">[0-9]+" | sed -n 's/id="yes-//; s/">/ /p' >> shudong-id-yes.data
		log "url ${cur_page_url} end"
		echo '' >&250
	}&
done

wait
log "all done"
