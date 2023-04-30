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

local TEMPLATE_PATH = "lua/nvim-license/templates/"

local function licenses()

  local template_files = vim.api.nvim_get_runtime_file(TEMPLATE_PATH.."*", true)

  local LICENSES = {}

  for _, file in ipairs(template_files) do
    if vim.endswith(file, "header.txt") then
      goto continue
    end
    local lc = {}
    local base = vim.fs.basename(file)

    local name = vim.split(base, ".txt")[1]

    lc["name"] = name
    lc["path"] = file
    lc["header"] = nil
    if #vim.api.nvim_get_runtime_file(TEMPLATE_PATH..name.."-header.txt", true) ~= 0 then
      lc["header"] = TEMPLATE_PATH..name.."-header.txt"
    end

    LICENSES[name] = lc
      ::continue::

  end

  return LICENSES
end

local function open_and_substitute(path, options)
  local f = io.open(path, "r")
  if f == nil then
    vim.api.nvim_err_writeln("Failed to read path: " .. path)
    return nil
  end
  local data = f:read("a")
  data = data:gsub("{{ year }}", options["year"]):gsub("{{ organization }}", options["author"]):gsub("{{ project }}", options["project"])
  f:close()
  return data


end


local function make_license(name, options)
  local license = licenses()[name]

  if license == nil then
    return nil
  end

  return open_and_substitute(license["path"], options)
end

local function make_header(name, options)
  local license = licenses()[name]

  if license == nil then
    return nil
  end

  if license["header"] == nil then
    return nil
  end

  return open_and_substitute(license["header"], options)
end

return {
  licenses = licenses,
  make_license = make_license,
  make_header = make_header
}
