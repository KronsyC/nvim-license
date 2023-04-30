-- Copyright (c) 2023 Samir Bioud
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
-- DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
-- OR OTHER DEALINGS IN THE SOFTWARE.
-- 


local template = require("nvim-license.template")


local M = {}

local configuration = {
	name = nil,
	year = nil,
	project = function()
		return nil
	end,
}

function M.setup(opts)
	if opts.year then
		configuration.year = opts.year
	else
		configuration.year = os.date("%Y")
	end

	if opts.name then
		configuration.name = opts.name
	else
		configuration.name = os.getenv("USER")
	end

	if opts.project then
		configuration.project = opts.project
	else
		-- Try to get the name of the current git repo (if any) for the project
		-- otherwise, we error
		local function get_project_name()
			local proc = io.popen("git rev-parse --show-toplevel", "r")
      
			local project_path = proc:read("a")
			local success = proc:close()

			if success then
				return vim.fs.basename(project_path)
			else
        vim.api.nvim_err_writeln("Failed to determine a project name from a git repository, please make a PROJECT file, containing the name of the project")
				return "<unknown>"
			end
		end
		configuration.project = get_project_name
	end
end

M.licenses = template.licenses

local function resolve_config()
	local project = configuration.project

	if project == nil then
		return nil
	end

	if type(project) == "function" then
		project = project()
	end

	return {
		project = project,
		author = configuration.name,
		year = configuration.year,
	}
end

local function command(name, description, argcnt, callback, complete)
	vim.api.nvim_create_user_command(name, callback, {
		desc = description,
		nargs = argcnt,
		complete = complete,
	})
end

local function rewrite_as_comment(str)
	local comment_fmt = vim.api.nvim_buf_get_option(0, "commentstring")
  if comment_fmt == "" or comment_fmt == nil then
    return str
  end
	local lines = vim.split(str, "\n")

	local final_text = ""

	for _, text in pairs(lines) do
		final_text = final_text .. string.gsub(comment_fmt, "%%s", text) .. "\n"
	end
	return final_text
end

function M.create_license(name)
	local license_text = template.make_license(name, resolve_config())

	if license_text == nil then
		return nil
	end

	return license_text
end

function M.create_header(name)
	local license_text = template.make_header(name, resolve_config())

	if license_text == nil then
		return nil
	end

	return license_text
end

M.commentify = rewrite_as_comment

local function create_commands()
	-- Get a list of all licenses for autocomplete purposes
	local licenses = {}
	local header_licenses = {}
	local l = template.licenses()
	for k, v in pairs(l) do
		licenses[#licenses + 1] = k
		if v.header then
			header_licenses[#header_licenses + 1] = k
		end
	end

	command("License", "write the chosen license to the current buffer", 1, function(args)
		local license_text = M.create_license(args.args)

		if license_text == nil then
			vim.api.nvim_err_writeln("Unrecognized license type: " .. args.args)
			return
		end
		vim.api.nvim_put(vim.split(license_text, "\n"), "l", true, true)
	end, function(arg)
		local matches = {}

		for _, v in ipairs(licenses) do
			if vim.startswith(v, arg) then
				matches[#matches + 1] = v
			end
		end
		return matches
	end)

	command("LicenseHeader", "write the chosen license header as a comment to the current buffer", 1, function(args)
		local license_text = M.create_header(args.args)
		if license_text == nil then
			vim.api.nvim_err_writeln("Unrecognized header type: " .. args.args)
      return nil
		end
		license_text = rewrite_as_comment(license_text)
		vim.api.nvim_put(vim.split(license_text, "\n"), "l", true, true)
	end, function(arg)
		local matches = {}

		for _, v in ipairs(header_licenses) do
			if vim.startswith(v, arg) then
				matches[#matches + 1] = v
			end
		end
		return matches
	end)
end


create_commands()
return M
