# Gather Image Files script for ConTeXt

## Requirements

- For this form of the script: macOS. (For other OSs, adapt the copy command and other things.)
- Lua, probably 5.1 or later.
- [ConTeXt](https://wiki.contextgarden.net), obviously.

## What it does

It copies all image files from the image paths used in your job into a configurable folder.

## How to use

The script reads the image paths from the table in the *\<job-name\>-figures-usage.lua* file.

For this file to be created, you have to compile your job with `\enabletrackers[graphics.usage]` somewhere in your environment, or project/product/job file.

All paths in the *\<job-name\>-figures-usage.lua* file are relative, so you have to execute the script from within the same folder where ConTeXt created the *\<job-name\>-figures-usage.lua* file.
(The script does *not* depend on any special Lua packages or on LuaFileSystem, so we cannot simply set the working directory for the whole script in a non-convoluted way.)

So, to sum it up: 

1. Compile the Ctx job with `\enabletrackers[graphics.usage]`.
1. Place the script in the same folder as *\<job-name\>-figures-usage.lua*.
2. `cd` into that folder.
3. Do `./ctx-gather-image-files.lua`.


