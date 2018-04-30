################################
#
#  工具库，用来存放一些通用的方法
#
################################


# ha! 简易的log4shell
log(){
	echo "[`date +'%F %T'`] $1"
}

# 封装的线程控制器
# $1 要使用的管道
# $2 要使用的线程数
init_thread(){
	pipe_num=$1
	thread_num=$2

	fifo_path="/tmp/fifo_path_`date +%s`_${1}_${2}"
	mkfifo $fifo_path
	eval "exec ${pipe_num}<>${fifo_path}"
	rm $fifo_path

	for i in `seq 1 $thread_num`;
	do
		echo '' >&${pipe_num}
	done
	return $pipe_num
}

# 对curl的一层封装
# 1. 伪装下U-A
# 2. 模拟浏览器持久cookie的行为
# 3. 安静模式，不显示统计信息
# $@ 会被放在最后
curl_(){
	curl -s --user-agent "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.119 Safari/537.36"  -b cookie -c cookie $@
}

# 类似于Stream.map()的封装，使得自定义函数支持管道调用
# $1 函数名
map(){
	function_name=$1
	while read line
	do
		$function_name "$line"
	done
}

