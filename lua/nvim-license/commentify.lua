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

local comment_ft = require("Comment.ft")
local comment_U = require("Comment.utils")


-- local function parse_comments_opt(cs)
-- 	local parts = vim.split(cs, ",")
--
--
-- 	for _, p in pairs(parts) do
-- 		local pack = vim.split(p, ":")
-- 		local flags, content = pack[1], pack[2]
-- 		print(flags, content)
--
-- 		if flags:find("n") then
-- 			-- Nested comments are not supported
-- 		end
-- 		if flags:find("b") then
-- 			-- Blank comment
-- 		end
-- 		if flags:find("f") then
-- 			-- First
-- 		end
--
-- 		if flags:find("s") then
-- 			-- Three-piece start
-- 		end
-- 		if flags:find("m") then
-- 			-- Three-piece center
-- 		end
-- 		if flags:find("e") then
-- 			-- Three-piece end
-- 		end
-- 		if flags:find("l") then
-- 			-- Left-aligned threepice center + end
-- 		end
-- 		if flags:find("r") then
-- 			-- Right-aligned threepice center + end
-- 		end
--
--     -- These cases are only relevant for typing out comments
--     -- if flags:find("O") then 
--     --   
--     -- end
--     -- if flags:find("x") then
--     --   
--     -- end
-- 	end
-- end

local function commentify(str)
  local ft = vim.api.nvim_buf_get_option(0, "ft")
  local wrap = comment_ft.get(ft, comment_U.ctype.linewise)

  if wrap == nil then
    return nil
  end

  print(vim.inspect(wrap))

  local lines = vim.split(str, "\n")

  local ret = ""
  for _, l in pairs(lines) do
    l = " " .. l
    ret = ret .. wrap:gsub("%%s", l) .. "\n"
  end
  return ret
	-- for _, p in pairs(parts) do
	-- 	-- The comment text that we want always starts with a colon character
	-- 	if vim.startswith(p, ":") then
	-- 		single_line_parts[#single_line_parts + 1] = p:sub(2)
	-- 	end
	-- end
	--
	-- local lines = vim.split(str, "\n")
	-- if #single_line_parts ~= 0 then
	-- 	-- Do a linewise substitution of the comment pattern
	-- 	local ret = ""
	--
	-- 	for _, l in pairs(lines) do
	-- 		ret = ret .. single_line_parts[1] .. " " .. l .. "\n"
	-- 	end
	-- 	return ret
	-- else
	-- 	-- Fall back to commentstring substitution
	-- 	local commentstr = vim.api.nvim_buf_get_option(0, "commentstring")
	-- 	if commentstr == nil or commentstr == "" then
	-- 		return str
	-- 	end
	-- 	local ends = vim.endswith(commentstr, "%s")
	--
	-- 	if ends then
	-- 		-- line-wise comment, per-line substitution
	--
	-- 		local ret = ""
	-- 		for _, l in pairs(lines) do
	-- 			ret = ret .. commentstr:gsub("%%s", l) .. "\n"
	-- 		end
	-- 		return ret
	-- 	else
	-- 		-- block-style comment, full substitution
	-- 		local ret = commentstr:gsub("%%s", "\n" .. str)
	--
	-- 		return ret
	-- 	end
	-- end
end

return commentify
