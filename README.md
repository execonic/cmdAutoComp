# CmdAutoComp
`CmdAutoComp` is a tool for simplifying the implementation of auto-completion of commands. You can watch the [demo video](#demo-video) first to check if it meets your needs. It relies on the **`complete`** command on the Linux shell and a command tree file (with the suffix `.comp`) designed by me. After installing this tool, when you want to auto-complete a command, you just need to make a `.comp` file like [example](#example).

## Usage
You can refer to [example](#example) to try it out.

1. Append the contents of the `bashrc` to the `.bashrc` in your home directory. And replace `path/to/shell-cmd-comp.sh` with the path where you put `shell-cmd-comp.sh`.
2. Run **`source ~/.bashrc`**. This will create a directory named `.shellCmdComp.d` and export a environment variable `SHELL_CMD_COMP_DIR`.
3. In this step, you can create a file with the `.comp` suffix and put it in the `~/shellCmdComp.d` directory. This file is the key to auto-complete commands. Refer to [.comp File](#comp-file) to get the details.
4. Run **`complete -F _shell_cmd_complete `***`<cmd-name>`*.
5. Test your command.

## comp File
Sub-commands are organized into a **tree** in the `.comp` file. The coding rules for the `.comp` file and the **tree** are as follows.

- The file name before the suffix must be the same as your main command.
- The first line is reserved. You can write anything or nothing on this line.
- Subsequent lines are used to enumerate sub-commands. These sub-commands are organized in a tree. Each child command is indented **one tab** back from the parent command.
- The first-level sub-command should be indented **one tab** from the beginning of the line
- Each level of command nodes should start with a dedicated line that determines how to handle the command nodes at the current level. Only the following symbols can be used for dedicated lines.
  - `&` All sub-commands of the current level can be used together.
  - `@` Only one sub-command of the current level can be used.
  - `*` Current sub-command supports any input parameter.

## Example
There is a command `test` which supports the following sub-commands.

- `--option1 param11`
- `--option1 param12`
- `--option1 param12 <anything>`
- `--option1 param13 param131`
- `--option1 param13 param132`
- `--option2 param21`
- `--option2 param22`
- `--option3 param31`
- `--option3 param32`
- `--option1`, `--option2` and `--option3` can be used together.
- `param11`, `param12` and `param13` under `--option1` can be used together.
- `param21` and `param22` under `--option2` can be used together.

Then the name of the `.comp` file must be `test.comp`. The contents of this file are as follows.

```
Anything
	&
	--option1
		&
		param11
		param12
			*
		param13
			@
			param131
			param132
	--option2
		&
		param21
		param22
	--option3
		@
		param31
		param32
```

The command log is shown below.
```
source@debian:cmdAutoComp$ ls
1  bashrc  LICENSE  README.md  shell-cmd-comp.sh  test  test.comp
source@debian:cmdAutoComp$ pwd
/home/source/opensource/mine/cmdAutoComp
source@debian:cmdAutoComp$ vim ~/.bashrc
source@debian:cmdAutoComp$ tail -1 ~/.bashrc
source /home/source/opensource/mine/cmdAutoComp/shell-cmd-comp.sh
source@debian:cmdAutoComp$ source ~/.bashrc
source@debian:cmdAutoComp$ ls ~/.shellCmdComp.d
source@debian:cmdAutoComp$ vim ~/.shellCmdComp.d/test.comp
source@debian:cmdAutoComp$ ls ~/.shellCmdComp.d
test.comp
source@debian:cmdAutoComp$ cat ~/.shellCmdComp.d/test.comp
Anything
	*
	--option1
		*
		param11
		param12
		param13
			@
			param131
			param132
	--option2
		*
		param21
		param22
	--option3
		@
		param31
		param3

source@debian:cmdAutoComp$ cat test
#!/bin/bash
source@debian:cmdAutoComp$ chmod +x test
source@debian:cmdAutoComp$ complete -F _shell_cmd_complete ./test
source@debian:cmdAutoComp$ test
1                  .git/              README.md          test
bashrc             LICENSE            shell-cmd-comp.sh
source@debian:cmdAutoComp$ ./test --option
--option1  --option2  --option3
```
## Demo Video

[](https://github.com/siyuanl96/cmdAutoComp/assets/27429124/91e40237-e44a-409e-834d-896dda3cbbcf)

