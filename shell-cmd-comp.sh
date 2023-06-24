#!/bin/bash
# Author:	Siyuan Liu
# E-mail:	siyuanl96@gmail.com

# export SHELL_CMD_COMP_DIR="/home/`whoami`/.shellCmdComp.d/"
SHELL_CMD_COMP_DIR=".shellCmdComp.d/"

if [ ! -d "${SHELL_CMD_COMP_DIR}" ]; then
	mkdir ${SHELL_CMD_COMP_DIR}
fi

function _shell_cmd_complete_push_stack() {
	local line=`expr $1 + 1`
	local indent=$2
	local stack=""
	local mark=""
	local cmd_tree=$3

	mark=`sed -n ''$line',+0p' $cmd_tree | sed 's/[ \t]//g'`

	# echo $cmd_tree
	# echo begin
	# cat $cmd_tree
	# echo end

	line=`expr $line + 1`

	if [ "$mark" == "*" ]; then
		stack=`sed -n ''${line}',/^'${indent%??}'\S/p' $cmd_tree | sed -n '/^'${indent}'\S/p'`
		echo $stack
	fi
}

function _shell_cmd_complete() {
	COMPREPLY=()
	local cur=${COMP_WORDS[COMP_CWORD]}
	local cmd=${COMP_WORDS[0]}

	# The first line is reserved.
	local line=2
	local indent="\t"
	local cmd_tree="${SHELL_CMD_COMP_DIR}${cmd}.comp"
	local match=""
	local stack=()
	local arr=()
	local opts=""
	local mark=""
	local level=1

	mark=`sed -n '2,2p' $cmd_tree | sed 's/[ \t]//g'`
	# echo "mark:$mark"

	if [ "$mark" == "*" ]; then
		stack[1]=`sed -n '3,/^'${indent%??}'\S/p' $cmd_tree | sed -n '/^\t\S/p'`
		# stack=$(echo "${stack[*]}")
		stack[1]=`echo ${stack[1]} | sed 's/[\t\n]//g'`
		stack[1]="${stack[1]} "
		# echo "stack:${stack[0]}"
	fi

	# if [ $COMP_CWORD -gt 1 ]; then
	# 	# Find the start line of the first sub-command.
	# 	match="\t${COMP_WORDS[1]}"
	# 	line=`sed -n '/'${match}'/=' $cmd_tree`

	# 	if [ "$line" == "" ]; then
	# 		return 0
	# 	fi
	# fi

	# Find next level sub-command.
	for i in $(seq 2 $COMP_CWORD)
	do
		stack[level]=`echo ${stack[level]} | sed 's/'${COMP_WORDS[i-1]}'/ /'`
		# echo "stack[$level]Begin: ${stack[level]} :end"
		match="${indent}${COMP_WORDS[i-1]}"

		# echo "line:$line match:$match"

		line=`sed -n ''${line}',/'${match}'/=' $cmd_tree`

		arr=($line)
		line=${arr[-1]}

		if [ "$line" == "" ]; then
			indent=${indent%??}
			level=`expr $level - 1`
			return 0
		else
			indent="${indent}\t"
			level=`expr $level + 1`
		fi

		stack[level]=$(_shell_cmd_complete_push_stack $line $indent $cmd_tree)

		# echo "Search from line:$line"
		# _shell_cmd_complete_push_stack $line $indent $cmd_tree
	done

	opts=`sed -n ''${line}',/^'${indent%??}'\S/p' $cmd_tree | sed -n '/^'${indent}'\S/p' | sed -n '/[^*@$]$/p'`

	COMPREPLY=( $(compgen -W '$opts' -- $cur) )

	return 0
}
