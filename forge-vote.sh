#! /bin/bash
##############################################################
#
#
#       刷赞
#
#
##############################################################

# env
cd `dirname $0`
source utils.sh

# $1 秘密id
# $2 刷多少
forge_vote(){
	init_thread 249 10
	for i in `seq 1 $2`
	do
		read -u249
		{
			curl -s -d "id=${1}&kind=1" "http://www.6our.com/index.php/Reply/checkVote2"
			echo '' >&249
		} &
	done
	wait
	log "done"
}

forge_vote $@



