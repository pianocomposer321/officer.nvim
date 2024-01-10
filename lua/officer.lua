local config = require("officer.config")

local M = {}

function M.spawn_cmd(cmd, params)
  local overseer = require("overseer")

  local components = config.get_components(params)

  local task = overseer.new_task({
    cmd = cmd,
    components = components,
  })
  task:start()
end

M.setup = config.setup

return M
