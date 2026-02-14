return {
  desc = "Open Trouble quickfix when the errorformat finds a match",
  params = {
    close_on_exit = {
      desc = "Close Trouble when task exits without errors",
      type = "boolean",
      default = false,
    },
  },
  constructor = function(params)
    return {
      on_complete = function(self, _task, status, _result)
        local builtin_qf_list = vim.fn.getqflist()

        if status == 'SUCCESS' or #builtin_qf_list == 0 then
          if params.close_on_exit then
            require("trouble").close()
          end
          return
        end

        local trouble_qf_list = require("trouble.sources.qf").get_list()
        if #trouble_qf_list == 0 then
          -- This means the quickfix list contains invalid entries
          -- Open the builtin quickfix list in that case.
          if params.close_on_exit then
            require("trouble").close()
          end
          vim.cmd("botright copen")
          return
        end

        require("trouble").open("quickfix")
      end,
    }
  end,
}
