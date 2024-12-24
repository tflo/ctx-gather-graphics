# Gather Graphics script for ConTeXt

Version 0.9.2-alpha (2024-12-24)

## Requirements

- For this form of the script: **macOS**. 
    - (For other OSs, you may have to adapt the copy command, path component delimiters, etc.)
- **Lua**, probably 5.1 or later.
    - Special packages/libraries or LuaFileSystem are *not* required.
- [**ConTeXt**](https://wiki.contextgarden.net), obviously.

## What the script does

It exports all graphic files used in your Ctx job to an export folder. Files will be grouped by job name, converted files will be grouped into a *_converted* subdirectory per job-name folder.

This allows you to quickly gather all used graphic files of your job, no matter from what location they were pulled, much like you would do when “packaging” an InDesign job or similar.

## Setup

### Destination directory

The only setup that the script requires is the destination directory where you want to copy your graphic files to.

For this, simply set the `destdir` variable (at the top of the script) to an absolute or relative path. Spaces in the path should be OK.

You don’t have to change the destination directory for different jobs, the script will dynamically create a *\<job-name\>* subdirectory inside your set `destdir` directory.

### Copy command

By default, `cp` is used with the `-n` option. This means that already existing files will not be overwritten with files with the same name. The output of the script tells you how many files have been exported and how many have been skipped because a file with the same was already present. 

If the amount of skipped dupe-name files is not too high, the script will print a list of the skipped paths.

To always overwrite, use the `-f` option. Check out `man cp` for more info.


## How to use

The script reads the graphic file paths from the table in the *\<job-name\>-figures-usage.lua* file.

For this file to be created, you have to compile your job with `\enabletrackers[graphics.usage]` somewhere in your environment, or in your project/product/job file.

In order to find the *\<job-name\>-figures-usage.lua* file and to resolve the relative graphic paths in that file, it is necessary to execute the script from within the same folder where ConTeXt created the *\<job-name\>-figures-usage.lua* file.

So, to sum it up: 

1. Set the destination path in the script (one-time).
2. Compile a Ctx job with `\enabletrackers[graphics.usage]` active.
3. Place the script in the same folder where the *\<job-name\>-figures-usage.lua* file has been created.
4. `cd` into that folder.
5. Run the script with `./ctx-gather-graphics.lua`.


