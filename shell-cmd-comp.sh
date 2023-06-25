#!/bin/bash
# Author:	Siyuan Liu
# E-mail:	siyuanl96@gmail.com

export SHELL_CMD_COMP_DIR="/home/`whoami`/.shellCmdComp.d/"
# For debug
# SHELL_CMD_COMP_DIR=".shellCmdComp.d/"

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

	line=`expr $line + 1`

	if [ "$mark" == "&" ]; then
		stack=`sed -n ''${line}',/^'${indent%??}'\S/p' $cmd_tree | sed -n '/^'${indent}'\S/p'`
		echo $stack
	fi
}

function _shell_cmd_complete_cmd_end() {
	local cmd_tree=$1
	local line=$2
	local indent=$3
	local opts=""

	opts=`sed -n ''${line}',/^'${indent%??}'\S/p' $cmd_tree | sed -n '/^'${indent}'\S/p' | sed -n '/[^&@$]$/p'`

	if [ "$opts" == "" ]; then
		echo 1
	fi
}

function _shell_cmd_complete() {
	COMPREPLY=()
	local cur=${COMP_WORDS[COMP_CWORD]}
	local cmd=${COMP_WORDS[0]}

	# The first line is reserved.
	local line=1
	local indent="\t"
	local cmd_tree="${SHELL_CMD_COMP_DIR}${cmd}.comp"
	local match=""
	local stack=()
	local stack_line=()
	local arr=()
	local opts=""
	local level=0
	local push=1
	local same=0

	# process sub-command
	for i in $(seq 2 $COMP_CWORD)
	do
		if [ $push -eq 1 ]; then
			level=`expr $level + 1`
			stack_line[$level]=$line
			stack[level]=$(_shell_cmd_complete_push_stack $line $indent $cmd_tree)
		else
			indent=${indent%??}

			# Find the level to which the previous cmd belongs.
			local cmd_level=$level

			while [ $cmd_level -gt 0 ]
			do
				if [ "${stack[cmd_level]}" != "" ]; then
					match="${COMP_WORDS[i-1]//\//\\/}"
					local belong=`echo ${stack[cmd_level]} | sed -n '/'${COMP_WORDS[i-1]}'/p'`

					if [ "$belong" != "" ]; then
						break
					fi
				fi

				cmd_level=`expr $cmd_level - 1`
				indent=${indent%??}
			done

			# echo "cmd_level:$cmd_level, level:$level"

			if [ "$cmd_level" != "$level" ]; then
				level=$cmd_level

				while [[ "${stack[level]}" == " " ]]
				do
					if [ $level -lt 1 ]; then
						break
					fi

					level=`expr $level - 1`
					indent=${indent%??}
				done
			fi

			line=${stack_line[level]}
		fi

		match="${COMP_WORDS[i-1]//\//\\/}"
		stack[level]=`echo ${stack[level]} | sed 's/'${match}'/ /'`

		# echo "stack[$level]B: ${stack_line[level]} ${stack[level]} :E"

		match="${indent}${match}"

		# echo "line:$line match:$match"

		line=`sed -n ''${line}',/'${match}'/=' $cmd_tree`

		arr=($line)
		line=${arr[-1]}

		local end=$(_shell_cmd_complete_cmd_end $cmd_tree $line "${indent}\t")

		if [ "$end" == "1" ]; then
			# echo "POP stack"
			push=0
		else
			push=1
		fi

		indent="${indent}\t"
	done

	# echo "Search from line:$line indent:$indent"

	opts=`sed -n ''${line}',/^'${indent%??}'\S/p' $cmd_tree | sed -n '/^'${indent}'\S/p' | sed -n '/[^&@$]$/p'`

	if [ "$opts" == "" ]; then
		# Return to the level where sub-commands can be appended
		for j in $(seq 0 $level)
		do
			# echo "Back stack[`expr $level - $j`]:${stack[level-j]}"

			if [ "${stack[level-j]}" != "" ]; then
				opts="${opts}${stack[level-j]}"
			fi
		done
	fi

	# '*' means it supports any input parameters.
	if [[ "${opts}" =~ "*" ]]; then
		_filedir
	else
		COMPREPLY=( $(compgen -W '$opts' -- $cur) )
	fi

	return 0
}
