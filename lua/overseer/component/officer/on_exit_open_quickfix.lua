return {
  desc = "Open quickfix window when task exits",
  params = {
    open_cmd = {
      desc = "Command to run to open the quickfix list",
      type = "enum",
      choices = { "copen", "cwindow" },
      default = "copen",
    },
    height = {
      type = "integer",
      optional = true,
    },
  },
  constructor = function(params)
    return {
      on_exit = function()
        local open_cmd = "botright " .. params.open_cmd
        if params.height then
          open_cmd = open_cmd .. params.height
        end
        vim.cmd(open_cmd)
      end,
    }
  end,
}
