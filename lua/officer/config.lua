local M = {}

---@class DispatchOverseer.Config
---@field use_base_components boolean
---@field components table|fun(params: table): table
---@field create_mappings boolean
---@field create_commands boolean
---@field strategy? string|table

---@class DispatchOverseer.ConfigParam
---@field use_base_components? boolean
---@field components? table|fun(params: table): table
---@field create_mappings? boolean
---@field create_commands? boolean
---@field strategy? string|table

---@param params table
local function base_components(params)
  return {
    {
      "on_output_quickfix",
      errorformat = vim.o.efm,
      open_on_match = not params.bang,
      tail = false,
      open_height = 8,
      close = true
    },
    {
      "officer.open_on_start",
      modifier = "botright vertical",
      close_on_exit = params.bang and "always" or "never",
      size = function() return vim.o.columns * 0.4 end
    },
    { "unique", replace = false, },
    "on_exit_set_status",
  }
end

---@type DispatchOverseer.Config
local config = {
  use_base_components = true,
  components = {},
  create_mappings = false,
  create_commands = true,
}

---@type DispatchOverseer.Config
M.config = setmetatable({}, { __index = function(_, key) return config[key] end })

---@param key string
M.get_config_value = function(key)
  return config[key]
end

---@param user_config? DispatchOverseer.ConfigParam
M.setup = function(user_config)
  config = vim.tbl_extend("force", config, user_config or {})
  if config.create_commands then
    M.setup_commands()
  end
  if config.create_mappings then
    M.setup_mappings()
  end
end

function M.setup_commands()
  local officer = require("officer")

  local cmd_opts = {
    desc = "",
    nargs = "*",
    bang = true,
    complete = "file",
  }
  vim.api.nvim_create_user_command("Make", function(params)
    local args = vim.fn.expandcmd(params.args)
    local cmd, num_subs = vim.o.makeprg:gsub("%$%*", args)
    if num_subs == 0 then
      cmd = cmd .. " " .. args
    end

    -- local strategy = opts.strategy
    -- strategy.open_on_start = not params.bang
    officer.spawn_cmd(cmd, params)
  end, cmd_opts)

  vim.api.nvim_create_user_command("Run", function(params)
    local cmd = vim.fn.expandcmd(params.args)
    officer.spawn_cmd(cmd, params)
  end, cmd_opts)

  -- vim.api.nvim_create_user_command("RunOpen", function(params)
  --   local cmd = vim.fn.expandcmd(params.args)
  --   officer.spawn_cmd(cmd, params)
  -- end, cmd_opts)
end

function M.setup_mappings()
  vim.keymap.set("n", "m<SPACE>", ":Make<SPACE>")
  vim.keymap.set("n", "m<CR>", ":Make<CR>")
  vim.keymap.set("n", "m!", ":Make!<SPACE>")
  vim.keymap.set("n", "M<SPACE>", ":Run<SPACE>")
  vim.keymap.set("n", "M<CR>", ":Run<CR>")
  vim.keymap.set("n", "M!", ":Run!<SPACE>")
end

---@param params table
function M.get_components(params)
  local components = config.use_base_components and base_components(params) or {}

  local additional_components = config.components
  if type(additional_components) == "function" then
    additional_components = additional_components(params)
  end

  for _, comp in ipairs(additional_components) do
    table.insert(components, comp)
  end

  return components
end

return M
