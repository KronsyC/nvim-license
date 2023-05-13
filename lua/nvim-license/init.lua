-- Copyright (c) 2023 Samir Bioud
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this neovim create commented textpermission notice shall be included in all
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
local make_comment = require("nvim-license.commentify")
local M = {}

local configuration = {
	name = nil,
	year = nil,
	project = function()
		return nil
	end,
}

local function proc(a)
	local exit = os.execute(a)

	if exit ~= 0 then
		return nil
	end
	local p = io.popen(a)
	local content = p:read("*a"):gsub("^%s*(.-)%s*$", "%1")
	return content
end

local function git_config(vname)
	return proc("git config --get " .. vname)
end

local function git_repo_name()
	return proc("git rev-parse --show-toplevel")
end

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
		local function get_project_name()
			local configured_name = git_config("project.name")
			if configured_name ~= nil then
				return configured_name
			else
				local repo_name = git_repo_name()
				if repo_name ~= nil then
					return vim.fs.basename(repo_name)
				else
					vim.api.nvim_err_writeln(
						"Failed to determine a project name from a git repository, please use `git config project.name <NAME>`"
					)
					return "<unknown>"
				end
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

function M.fetch_raw_license(name)
	local lc = template.licenses()[name]

	if lc == nil then
		return nil
	end
	return template.read(lc.path)
end

function M.fetch_raw_header(name)
	local lc = template.licenses()[name]

	if lc.header == nil then
		return nil
	end

	return template.read(lc.header)
end

function M.autolicense()
	local license_type = git_config("project.license")

	if license_type == nil then
		vim.api.nvim_err_writeln(
			"Autolicense features do not work without first setting the license variable using `git config project.license <LICENSE>`"
		)
		return nil
	end

	local content = M.create_header(license_type:lower())

	if content == nil then
		vim.api.nvim_err_writeln("The configured project license type '" .. license_type .. "' is not recognized")
		return nil
	end

	return content
end

M.commentify = make_comment

local function write(text)
	local line = vim.api.nvim_win_get_cursor(0)[1]

	vim.api.nvim_buf_set_lines(0, line, line, false, vim.split(text, "\n"))
end

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
		write(license_text)
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
		license_text = make_comment(license_text)
		write(license_text)
	end, function(arg)
		local matches = {}

		for _, v in ipairs(header_licenses) do
			if vim.startswith(v, arg) then
				matches[#matches + 1] = v
			end
		end
		return matches
	end)

	command("AutoLicense", "infer a license to insert to the file based on git config", 0, function()
		local license_text = M.autolicense()
		if license_text == nil then
			return
		end
		license_text = make_comment(license_text)
		write(license_text)
	end)
end

create_commands()

return M
