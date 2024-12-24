#!/usr/bin/env lua


-- Version 0.9.2-alpha (2024-12-24)

-- BEGIN Settings
-- Set the variable `destdir` to the destination directory where you want to gather the graphic files. It will be created if it doesn't exist yet.
-- Path can be absolute (example 1), or relative (example 2) to the script location. Spaces should be OK.
local destdir = '$HOME/_tmp/Ctx Gathered Graphics' -- Absolute path example.
-- local destdir = '../gathered_graphics' -- Relative path example.
-- NOTE: The script will dynamically create a <job-name> subdirectory inside your set `destdir` directory.

-- Set the copy cmd we want to use
-- `-c` ensures that `cp` makes APFS clones if on the same disk (macOS), which is a good thing.
-- With the `-n` option, duplicate filenames will not be overwritten. `-f` to overwrite.
-- Check out `man cp` for more info.
local copycmd = 'cp -c -p -n'
-- Set this to true to put duplicate filenames that would otherwise be skipped into numbered subdirectories.
-- This can help you find out which files have duplicate names and why.
-- Activate this only if the job's export directory is empty; otherwise you get every existing file in a separate folder!
local isolate_dupe_names = false
-- END Settings

-- BEGIN Lua script
local graphicstable_file_suffix = '-figures-usage.lua'
-- Let's identify the '...figures-usage.lua' file in the current directory.
-- `os.execute` only returns a status (e.g. `true`), so we have to write it to a tmp file.
local tmpout = os.tmpname()
-- The shell cmd arg is always a single string, so we can just concatenate.
os.execute("find . -type f -name '*" .. graphicstable_file_suffix .. "' > " .. tmpout)
-- Read the path from the tmp file and delete the file.
local graphicstable_file
for line in io.lines(tmpout) do
	graphicstable_file = line
	break -- There should be only one line.
end
os.remove(tmpout)

if not graphicstable_file then -- Check if `find` did actually find the file.
	print 'No `*-figures-usage.lua` file found! Aborting.'
	return
end

-- Create our final destination dir.
local jobname = graphicstable_file:sub(1, -(#graphicstable_file_suffix+1)):match('[^/]+$')
local jobdir = string.format('%s/%s', destdir, jobname)
local dircreated = os.execute(string.format('mkdir -p "%s"', jobdir))
if not dircreated then
	print('The destination job directory `' .. jobdir .. '` could not be created! Aborting.')
	return
end

-- Read the table from the graphicstable file.
local graphicstable = dofile(graphicstable_file)
-- Build new tables consisting only of the paths.
local graphicpaths, graphicpaths_converted = {}, {}
for _, v in ipairs(graphicstable.found) do
	table.insert(graphicpaths, v.foundname)
	if v.converted or v.foundname ~= v.fullname then
		table.insert(graphicpaths_converted, v.fullname)
	end
end

local function copyfile(source, dest)
	return os.execute(string.format('%s "%s" "%s"', copycmd, source, dest))
end

local num_graphicpaths, num_graphicpaths_converted = #graphicpaths, #graphicpaths_converted
local print_overwrite_hint = false

if num_graphicpaths > 0 then
	local copied, num_failed, failed = nil, 0, {}
	for _, path in ipairs(graphicpaths) do
		copied = copyfile(path, jobdir)
		if not copied then
			num_failed = num_failed + 1
			table.insert(failed, path)
			if isolate_dupe_names then
				local failed_dir = jobdir .. '/_duplicate_names/' .. num_failed
				os.execute(string.format('mkdir -p "%s"', failed_dir))
				copyfile(path, failed_dir)
			end
		end
	end
	print(string.format('REGULAR GRAPHICS: %s of %s found paths exported; %s skipped (`-n` and file name already exists).', num_graphicpaths - num_failed, num_graphicpaths, num_failed))
	if num_failed > 0 then
		if num_failed > math.floor(num_graphicpaths / 2) then
			print_overwrite_hint = true
		else
			print 'Regular graphics skipped due to duplicate names:'
			for _, path in ipairs(failed) do
				print(path)
			end
		end
	end
else
	print 'No regular graphics found.'
end

if num_graphicpaths_converted > 0 then
	local jobdir_converted = jobdir .. '/_converted'
	local dircreated = os.execute(string.format('mkdir -p "%s"', jobdir_converted))
	if not dircreated then
		print('The destination directory for converted files `' .. jobdir_converted .. '` could not be created! Aborting.')
		return
	end
	local copied, num_failed, failed = nil, 0, {}
	for _, path in ipairs(graphicpaths_converted) do
		copied = copyfile(path, jobdir_converted)
		if not copied then
			num_failed = num_failed + 1
			table.insert(failed, path)
		end
	end
	print(string.format('CONVERTED GRAPHICS: %s of %s found paths exported; %s skipped (`-n` and file name already exists).', num_graphicpaths_converted - num_failed, num_graphicpaths_converted, num_failed))
	if num_failed > 0 then
		if num_failed > math.floor(num_graphicpaths_converted / 2) then
			print_overwrite_hint = true
		else
			print 'Converted graphics skipped due to duplicate names:'
			for _, path in ipairs(failed) do
				print(path)
			end
		end
	end
else
	print 'No converted graphics found.'
end
if print_overwrite_hint then
	print 'A HUGE AMOUNT OF GRAPHICS WAS SKIPPED DO TO DUPLICATE NAMES. Consider using `cp` with the `-f` option to always overwrite files, or empty your export directory before exporting.'
end
print 'Script completed, probably successfully.'
-- END Lua script

-- NOTE: It seems file conversion happens  mainly when Ctx takes an `.ai` file and then converts it to a PDF like
-- for example `m_k_i_v_S2_dimensions_ai_c60ccda70ef92e32d7a6334f31c23259.pdf`
