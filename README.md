# officer.nvim

Like dispatch.vim but using overseer.nvim.

## About

Officer.nvim is an alternative to tpope's vim-dispatch. Like dispatch, it allows you to
run programs asynchronously either using `:h makeprg` or using an arbitrary command.

Officer does not aim to be a drop-in replacment for dispatch however. In particular,
although there are equivalents of both the `:Make` and `:Start` commands (`:Make` and `:Run`),
there is no equivalent of the `:Dispatch` command, and at this point I do not plan to add it.

Officer uses [overseer.nvim](https://github.com/stevearc/overseer.nvim) to run tasks under the hood. This means that it benefits from
overseer's task management utilities (such as the task list) and modularity. You can customize
the behavior of tasks started from officer by changing the components that are added to
the overseer tasks. For more on this see the [configuration](#config) section, and also
read overseer.nvim's documentation.

## Setup

 - lazy.nvim (recommended):

```lua
{
  "pianocomposer321/officer.nvim",
  dependencies = "stevearc/overseer.nvim",
  config = function()
    require("officer").setup {
      -- config
    }
  end,
},
```

## Config

<table>
  <thead>
    <tr>
      <th>Variable</th>
      <th>Type/Default</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>components</code></td>
      <td>
        <code>table</code>
        <br />
        OR
        <br />
        <code>fun(params: table): table</code>
        <br /><br />
        Default: <code>{}</code>
      </td>
      <td>
        These are the components that are added to the overseer task.
        If <code>use_base_components</code> is <code>true</code>, these components
        will be appended to the <code>base_components</code> table,
        otherwise, they will replace it.
        <br /><br />
        If this is a function, it accepts one argument and returns the components.
        The argument is a table with information about the invocation of the <code>:Make</code>
        or <code>:Run</code> command. This is the same table that is passed to the function given
        to <code>nvim_create_user_command()</code>. See <code>:h nvim_create_user_command()</code>
        for more information.
      </td>
    </tr>
    <tr>
      <td><code>use_base_components</code></td>
      <td>
        <code>boolean</code>
        <br /><br />
        Default: <code>true</code>
      </td>
      <td>
        If this is <code>true</code>, each overseer task will use a base set of components.
        Set this to false if you want to add your own components through the <code>components</code>
        config value that will replace the base components.
        <br />
        Warning: many aspects of the plugin expect the base components to be there.
        Setting this value to <code>false</code> may have unexpected results.
      </td>
    </tr>
    <tr>
      <td><code>create_commands</code></td>
      <td>
        <code>boolean</code>
        <br /><br />
        Default: <code>true</code>
      </td>
      <td>
        Whether to create the <code>:Make</code> and <code>:Run</code> commands.
        See <a href="#commands">"Commands"</a>
      </td>
    </tr>
    <tr>
      <td><code>create_mappings</code></td>
      <td>
        <code>boolean</code>
        <br /><br />
        Default: <code>false</code>
      </td>
      <td>
        Whether to create the suggested mappings. See <a href="#mappings">"Mappings"</a>.
      </td>
    </tr>
  </tbody>
</table>

## Usage

### Commands

- `:Make [args]`

  Run `:h makeprg` with `args` in a terminal window that opens to the side.
  On completion, parse errors into the quickfix list using `:h errorformat`. If
  there are recognized errors, open the quickfix list.

- `:Make! [args]`

  Like `:Make [args]`, but don't open the quickfix list, and close the terminal window
  on completion.

- `:Run[!] {command} [args]`

  Like `:Make[!]`, but run `command` instead of `:h makeprg`.

### Mappings

> **🛈** These mappings are not applied by default. Set `create_mappings` to true in your config to 
use them. Or feel free to create your own mappings instead :).

Suggested Mappings:

 |  RHS      | LHS              |
 |-----------|------------------|
 | `m<SPACE>`| `:Make<SPACE>`   |
 | `m<CR>`   | `:Make<CR>`      |
 | `m!`      | `:Make!<SPACE>`  |
 | `M<SPACE>`| `:Run<SPACE>`    |
 | `M<CR>`   | `:Run<CR>`       |
 | `M!`      | `:Run!<SPACE>`   |


## Example

Here is a custom component that I have for all of my officer tasks. It keeps track
of the task history and allows you to restart the most recent one with a keybinding.

#### Setup call:

```lua
require("officer").setup {
  create_mappings = true,
  components = { "user.track_history" },
}
```

#### Mapping:

```lua
vim.keymap.set("n", "<LEADER><CR>", require("user.overseer_util").restart_last_task)
```

<details>
<summary><code>~/.config/nvim/lua/overseer/component/user/track_history.lua</code></summary>

```lua
local util = require("user.overseer_util")

return {
  desc = "Track files in a history so that the most recent can be restarted",
  constructor = function()
    return {
      on_start = function(_, task)
        util.register_task(task)
      end,
      on_dispose = function(_, task)
        util.unregister_task(task.id)
      end,
    }
  end,
}
```
</details>

<details>
<summary>
<code>~/.config/nvim/lua/user/overseer_util.lua</code>
</summary>

```lua
local M = {}

local task_history = {}
local tasks = {}

function M.register_task(task)
  tasks[task.id] = task
  table.insert(task_history, task.id)
end

function M.get_last_task()
  return tasks[task_history[#task_history]]
end

function M.restart_last_task()
  local task = M.get_last_task()
  if task then
    require("overseer").run_action(task, "restart")
  end
end

function M.unregister_task(task_id)
  tasks[task_id] = nil
  if task_history[#task_history] == task_id then
    task_history[#task_history] = nil
  end
end

return M
```
</details>
