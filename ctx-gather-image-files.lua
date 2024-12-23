#!/usr/bin/env Lua


-- Version 0.9 (2024-12-23)

-- REQUIREMENTS:
-- macOS
-- A `...figures-usage.lua` file must be in the same directory as the script.
-- This file will be created by Ctx when you compile with `\enabletrackers[graphics.usage]` in an early environment, or in the compilation file.
-- Lua, probably 5.1 or later.
-- This script must be run from the same directory where the compilation file is located.
-- Set the variable `destdir` to the destination directory where you want to gather the figure files. It will be created if it doesn't exist yet.
-- Path can be absolute (example 1), or relative (example 2) to the script location. Spaces should be OK.
local destdir = '$HOME/_tmp/Ctx Gathered Figs/BA P3.0-de' -- Absolute path
-- local destdir = '../gathered_figs' -- Relative path

-- Lua script BEGIN
-- Let's identify the '...figures-usage.lua' file in the current directory (usually in _compile.nosync.nobackup).
-- `os.execute` only returns a status (e.g. `true`), so we have to write it to a tmp file.
local tmp_output = os.tmpname()
-- The shell cmd arg is always a single string, so we can just concatenate.
os.execute("find . -type f -name '*figures-usage.lua' > " .. tmp_output)
-- Read the path from the content of our tmp file and delete the file.
local figusagetable_path
for line in io.lines(tmp_output) do
	figusagetable_path = line
	break -- There should be only one line.
end
os.remove(tmp_output)

if not figusagetable_path then -- Check if `find` did actually find the file.
	print 'No `*figures-usage.lua` file found! Aborting.'
	return
end

-- Read the table from the figusagetable file.
local figusagetable = dofile(figusagetable_path)
-- Set the copy cmd we want to use (`-c` ensures that `cp` makes APFS clones (macOS!)).
local copycmd = 'cp -c'
-- Create our destination dir. If it already exists, it's OK too.
-- The `-p` switch creates also missing intermediate directories along the way.
local dircreated = os.execute(string.format('mkdir -p "%s"', destdir))

if not dircreated then -- Check for success (`mkdir` may fail because of permissions).
	print('Destination directory `' .. destdir .. '` could not be created! Aborting.')
	return
end
-- Build a new table consisting only of the paths.
local figpaths = {}
for _, v in ipairs(figusagetable.found) do
	table.insert(figpaths, v.foundname)
	-- If `foundname` is different from `fullname`, we want both paths. See note at the end.
	if v.foundname ~= v.fullname then
		table.insert(figpaths, v.fullname)
	end
end
-- Now copy all the paths from the table into our destination dir.
for _, path in ipairs(figpaths) do
	os.execute(string.format('%s "%s" "%s"', copycmd, path, destdir))
end
print 'Script finished, probably successfully.'
-- Lua script END

-- NOTE: It seems `foundname` is different from `fullname` mainly when Ctx takes an `.ai` file and then converts it to a PDF like
-- for example `m_k_i_v_S2_dimensions_ai_c60ccda70ef92e32d7a6334f31c23259.pdf`
