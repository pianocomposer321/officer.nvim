local oui = require("officer.ui")

return {
  desc = "Open buffer on task start",
  params = {
    modifier = {
      desc = "Direction modifier for window created",
      type = "string",
      default = "",
    },
    close_on_exit = {
      desc = "Close the window on exit",
      type = "enum",
      choices = { "never", "success", "always" },
      default = "never",
    },
    size = {
      desc = "Size of the window to create",
      type = "opaque",
    },
  },
  constructor = function(params)
    return {
      bufnr = nil,
      on_start = function(self, task)
        self.bufnr = task:get_bufnr()
        oui.add_window_to_stack(self.bufnr)
        vim.api.nvim_win_set_buf(0, self.bufnr)
        require("overseer.util").scroll_to_end(0)
      end,
      on_exit = function(self, _, code)
        local close = params.close_on_exit == "always"
        close = close or (params.close_on_exit == "success" and code == 0)
        if close then
          oui.close_window(self.bufnr)
        end
      end,
      on_reset = function(self)
        oui.close_window(self.bufnr)
      end,
    }
  end,
}
