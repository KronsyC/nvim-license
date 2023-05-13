# Nvim-License

### A Simple neovim plugin for generating license files and headers

## Dependencies

- `numToStr/Comment.nvim`

## Installation

- `lazy.vim`

  ```lua
  {
    "KronsyC/nvim-license",
       opts = function()
          return {
             name = "YOUR_USERNAME",
             -- Optional
             -- year = "2023"
          }
    end,

    cmd = {
            "License",
            "LicenseHeader",
            "AutoLicense"
        },
    dependencies = {
        {"numToStr/Comment.nvim"}        
    } 

  }
  ```

## Configuration

The module exposes a simple `setup({options})` function to configure it.

`options: `

- `name : string` - The name to put on all licenses (default: username)
- `year : number` - The year for which the licenses should be addresses (default: current year)
- `project: string|func` - The name of the project, or a function to determine the name of the project (default: `git config project.name` or `<REPO_NAME>`)

## Commands

- **License** _{name}_ - Write the provided license at the cursor

- **LicenseHeader** _{name}_ - Write the provided license header at the cursor, as a comment.  
  note: not all licenses have a corresponding header

- **AutoLicense** - Automatically injects a license header, the license used is determined by `git config project.license`

## Lua API functions

- `setup({opts})` - Configure the plugin

- `create_license({name})` - Fetch the text content of a license

- `create_header({name})` - Fetch the text content of a license header

- `autolicense()` - Fetch whichever license is inferred to be in use by the project

- `commentify({text})` - Rewrite `text` as a comment for the current buffer's filetype (uses `Comment.nvim`)

- `fetch_raw_license({name})` - Fetch the raw, templated text of a license

- `fetch_raw_header({name})` - Fetch the raw, templated text of a header

### A special thank you to to [licenses/license-templates](https://github.com/licenses/license-templates) for providing the templates used by the plugin
