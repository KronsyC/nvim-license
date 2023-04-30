# Nvim-License

### A Simple neovim plugin for generating license files and headers

## Configuration

The module exposes a simple `config({options})` function to configure it.   

`options: `   

- `name : string` - The name to put on all licenses (default: username)
- `year : number` - The year for which the licenses should be addresses (default: current year)
- `project: string|func` - The name of the project, or a function to determine the name of the project (default: Name of the current git repository)
 


## Commands

- **License** *{name}* - Write the provided license at the cursor

- **LicenseHeader** *{name}* - Write the provided license header at the cursor, as a comment.   
note: not all licenses have a corresponding header


### A special thank you to to [licenses/license-templates](https://github.com/licenses/license-templates) for providing the templates used by the plugin

