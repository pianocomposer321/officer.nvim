local config = require("officer.config")

local M = {}

---@param cmd string
---@param params table
function M.spawn_cmd(cmd, params)
  local overseer = require("overseer")

  local components = config.get_components(params)

  local task = overseer.new_task({
    cmd = cmd,
    components = components,
    strategy = config.config.strategy
  })
  task:start()
end

M.setup = config.setup

return M
