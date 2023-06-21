# CmdAutoComp
A tool used to simplify the auto-completion of commands.

## Usage
1. Append the contents of the `bashrc` to the `.bashrc` in your home directory. And replace `path/to/shell-cmd-comp.sh` with the path where you put `shell-cmd-comp.sh`.
2. Run **`source ~/.bashrc`**. This will create a directory named `.shellCmdComp.d` and export a environment variable `SHELL_CMD_COMP_DIR`.
3. In this step, you can create a file with the `.comp` suffix and put it in the `~/shellCmdComp.d` directory. This file is the key to auto-complete commands. Refer to [.comp File](#comp-file) to get the details.
4. Run **`complete -F _shell_cmd_complete `***`<cmd-name>`*.
5. Test your command.

## comp File
The coding rules for the `.comp` file are as follows.

- The file name before the suffix must be the same as your main command.
- The first line is reserved. You can write anything or nothing on this line.
- Subsequent lines are used to enumerate sub-commands. These sub-commands are organized in a tree. Each child command is indented **one tab** back from the parent command.
- The first-level sub-command should be indented **one tab** from the beginning of the line

### Example
There is a command `test` which supports the following sub-commands.

- `--option1 param1`
- `--option1 param2`
- `--option2 param3`

Then the name of the `.comp` file must be `test.comp`. The contents of this file are as follows.

```
Anything
	--option1
		param1
		param2
	--option2
		param3
```

## Demo
```
source@debian:~/opensource/mine/cmdAutoComp$ ls
1  bashrc  LICENSE  README.md  shell-cmd-comp.sh  test  test.comp
source@debian:~/opensource/mine/cmdAutoComp$ pwd
/home/source/opensource/mine/cmdAutoComp
source@debian:~/opensource/mine/cmdAutoComp$ vim ~/.bashrc
source@debian:~/opensource/mine/cmdAutoComp$ source ~/.bashrc
source@debian:~/opensource/mine/cmdAutoComp$ ls ~/.shellCmdComp.d
source@debian:~/opensource/mine/cmdAutoComp$ vim test.comp
source@debian:~/opensource/mine/cmdAutoComp$ cat test.comp
Anything
        --option1
                param1
                param2
        --option2
                param3
source@debian:~/opensource/mine/cmdAutoComp$ mv test.comp ~/.shellCmdComp.d
source@debian:~/opensource/mine/cmdAutoComp$ ls ~/.shellCmdComp.d
test.comp
source@debian:~/opensource/mine/cmdAutoComp$ cat test
#!/bin/bash
source@debian:~/opensource/mine/cmdAutoComp$ chmod +x test
source@debian:~/opensource/mine/cmdAutoComp$ complete -F _shell_cmd_complete ./test
source@debian:~/opensource/mine/cmdAutoComp$ test
1                  .git/              README.md          test
bashrc             LICENSE            shell-cmd-comp.sh
source@debian:~/opensource/mine/cmdAutoComp$ ./test --option
--option1  --option2
source@debian:~/opensource/mine/cmdAutoComp$ ./test --option1 param
param1  param2
source@debian:~/opensource/mine/cmdAutoComp$ ./test --option1 param2
source@debian:~/opensource/mine/cmdAutoComp$ ./test --option2 param3
```
