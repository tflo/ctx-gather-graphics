#!/usr/bin/env lua


-- Version 0.9 (2024-12-23)

-- Set the variable `destdir` to the destination directory where you want to gather the graphic files. It will be created if it doesn't exist yet.
-- Path can be absolute (example 1), or relative (example 2) to the script location. Spaces should be OK.
local destdir = '$HOME/_tmp/Ctx Gathered Figs/BA P3.0-de' -- Absolute path example.
-- local destdir = '../gathered_figs' -- Relative path example.

-- Lua script BEGIN
-- Let's identify the '...figures-usage.lua' file in the current directory (usually in _compile.nosync.nobackup).
-- `os.execute` only returns a status (e.g. `true`), so we have to write it to a tmp file.
local tmp_output = os.tmpname()
-- The shell cmd arg is always a single string, so we can just concatenate.
os.execute("find . -type f -name '*figures-usage.lua' > " .. tmp_output)
-- Read the path from the content of our tmp file and delete the file.
local graphicstable_path
for line in io.lines(tmp_output) do
	graphicstable_path = line
	break -- There should be only one line.
end
os.remove(tmp_output)

if not graphicstable_path then -- Check if `find` did actually find the file.
	print 'No `*-figures-usage.lua` file found! Aborting.'
	return
end

-- Read the table from the graphicstable file.
local graphicstable = dofile(graphicstable_path)
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
local graphicpaths = {}
for _, v in ipairs(graphicstable.found) do
	table.insert(graphicpaths, v.foundname)
	-- If `foundname` is different from `fullname`, we want both paths. See note at the end.
	if v.foundname ~= v.fullname then
		table.insert(graphicpaths, v.fullname)
	end
end
-- Now copy all the paths from the table into our destination dir.
for _, path in ipairs(graphicpaths) do
	os.execute(string.format('%s "%s" "%s"', copycmd, path, destdir))
end
print 'Script finished, probably successfully.'
-- Lua script END

-- NOTE: It seems `foundname` is different from `fullname` mainly when Ctx takes an `.ai` file and then converts it to a PDF like
-- for example `m_k_i_v_S2_dimensions_ai_c60ccda70ef92e32d7a6334f31c23259.pdf`
