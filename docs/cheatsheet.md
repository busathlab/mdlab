## LINUX CHEATSHEET

- `man [command]`: Gives manual information on a command
- `ls`: Lists the contents of current directory. Use `ls -l` to give more details.
- `cd [directory name]`: Allows changing of directories. Use `cd ../` to go back a directory.
- `mkdir [directory name]`: Creates a directory.
- `rmdir [directory name]`: Removes a directory. Use `rm -r [directory name] to remove the directory and its contents.
- `rm [filename]`: Removes a file.
- `cp [original filename] [new filename]`: Copies a file. For example, to copy all text files in a location to a destination, use `cp *.txt destionation/.`
- `mv [original filename] [new filename]`: Moves a file.
- `vi [filename]`: Opens a file for viewing or editing.
- `grep [pattern] [file]`: Finds an expression in a file.
- `*`: Wildcard to match any string of characters.
- `?`: Wildcard to match any single character.
- `pwd`: Gives directory tree for present working directory.
- `chmod 774 [filename]`: Changes permissions to read, write, and execute for you and your group. Useful when a file says “permission denied.”
- `sed -i "s/[originalstring]/[newstring]" [filename]`: Replaces [originalstring] with [newstring] anywhere in a file.
- `squeue`: Shows all the jobs in the SLURM queue. Use `watch squeue` to update this list every two seconds. Add `-u [username]` to limit to a certain user.

**[Return to home page](https://busathlab.github.io/mdlab/index.html)**