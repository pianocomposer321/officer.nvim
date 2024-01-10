local util = require("officer.util")

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
