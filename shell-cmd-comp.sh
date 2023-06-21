#!/bin/bash
# Author:	Siyuan Liu
# E-mail:	siyuanl96@gmail.com

export SHELL_CMD_COMP_DIR="/home/`whoami`/.shellCmdComp.d/"

if [ ! -d "${SHELL_CMD_COMP_DIR}" ]; then
	mkdir ${SHELL_CMD_COMP_DIR}
fi

_shell_cmd_complete() {
	COMPREPLY=()
	local cur=${COMP_WORDS[COMP_CWORD]}
	local cmd=${COMP_WORDS[0]}

	# The first line is reserved.
	local line=2
	local indent="\t"
	local cmd_tree="${SHELL_CMD_COMP_DIR}${cmd}.comp"
	local match=""
	local arr=()
	local opts=""

	if [ $COMP_CWORD -gt 1 ]; then
		match="\t${COMP_WORDS[1]}"
		line=`sed -n '/'${match}'/=' $cmd_tree`

		if [ "$line" == "" ]; then
			return 0
		fi
	fi

	for i in $(seq 2 $COMP_CWORD)
	do
		match="${indent}${COMP_WORDS[i-1]}"
		indent="${indent}\t"
		line=`sed -n ''${line}',/'${match}'/=' $cmd_tree`

		arr=($line)
		line=${arr[0]}

		# echo $match
		# echo $line

		if [ "$line" == "" ]; then
			return 0
		fi
	done

	opts=`sed -n ''${line}',/^'${indent%??}'\S/p' $cmd_tree | sed -n '/^'${indent}'\S/p'`

	COMPREPLY=( $(compgen -W '$opts' -- $cur) )

	return 0
}
