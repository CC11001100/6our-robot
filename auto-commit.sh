#! /bin/bash
##############################################################
#
#
#
#       树洞鼓励师
#
#
#
##############################################################

# env 
cd `dirname $0`
source utils.sh

# 模拟登陆，保存cookie
login(){
	username="foo"
	passwd="bar"

	# 虽然不确定__hash__是做什么用的，但还是带上一下
	hash_param=`curl_ "http://www.6our.com/index.php/User/Index/login" | grep -oE "[0-9a-z]+\_[0-9a-z]+" | tail -n 1`
	curl_  -d "account=${username}&password=${passwd}&remember_me=1&submit=&__hash__=$hash_param" "http://www.6our.com/index.php/User/Index/checkLogin"  \
		| grep "登录成功" >> /dev/null

	if [ $? -ne 0 ];
	then
		log "login failed."
		exit -1	
	else
		log "login success" 
	fi
}

# 回复秘密
# $1 秘密id
# $2 回复内容
replay(){
	id=$1
	content=$2

	# 检测已有评论避免重复回复，此处的重复是指对每条秘密回复一次，而不是对每个pattern回复一次
	my_name="树洞鼓励师"
	curl_ -d "id=$id" "http://www.6our.com/index.php/Reply/showReply" | grep $my_name >> /dev/null
	if [ $? -eq 0 ];
	then
		return
	fi

	result=`curl_ -d "pid=${id}&anonymous=0&arcontent=${content}" "http://www.6our.com/index.php/Reply/checkReply2"`
	if [ $result -eq 1 ];
	then
	       log "replay $id $content success"
	else 
		log "replay $id $content failed"
	fi
	# 防止回复过快
	sleep 3
}

# 检查符合特定的条件则恢复特定内容
# $1 秘密内容
# $2 perl正则模式
# $3 回复内容
check_pattern_and_replay(){
	content=$1
	id=`echo $content | grep -oP 'id="content-\d+"' | grep -oP '\d+'`
	pattern=$2
	replay_content=$3

	echo $content | grep -P $pattern >> /dev/null
	[[ $? -eq 0 ]] &&  replay $id $replay_content
}

# 对单个的秘密检测处理
# $1 秘密元素，包含id和内容
process_single(){
	content=$1

	# 热血青年
	check_pattern_and_replay "$content" "需要帮助|阻碍|困难|梦想|努力" "加油，明天会更好！"
	
	# 孤独，纵有千种风情，更与何人说
	check_pattern_and_replay "$content" "(烦|讨厌|不喜欢).*社交" "跟人打交道是很难的事"
	
	# 自杀倾向
	check_pattern_and_replay "$content" "离开人世|自杀|我死了" "活着才有希望"

	# 拯救颜值
	check_pattern_and_replay "$content" "长的丑" "长的丑的来看下我长得有多挫，助你找回信心 :)"
}

# 监控第一页 
monitor(){
	while true;
	do
	 	curl_ "http://www.6our.com/qiushi" | tr -d "\r\n" | grep -oP 'id="content-\d+".+?</div>' | map "process_single"
		log "look first page over"
		sleep 10
	done
}

login
monitor

