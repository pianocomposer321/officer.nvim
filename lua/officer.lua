local config = require("officer.config")

local M = {}

function M.spawn_cmd(cmd, params)
  local overseer = require("overseer")

  local components = config.config.base_components
  if type(components) == "function" then components = components(params) end

  local additional_components = config.config.additional_components
  if type(additional_components) == "function" then
    additional_components = additional_components(params)
  end

  for _, comp in ipairs(additional_components) do
    table.insert(components, comp)
  end

  local task = overseer.new_task({
    cmd = cmd,
    components = components,
  })
  task:start()
end

M.setup = require("officer.config").setup

return M
