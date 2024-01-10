local stack = {}

local augroup = vim.api.nvim_create_augroup("officer_open_on_start", {})

local M = {}

local get_size = function() return vim.o.columns * 0.4 end

M.resize_windows_on_stack = function()
  local count_windows = #stack
  local each_height = math.floor(vim.o.lines / count_windows)
  for _, window in ipairs(stack) do
    vim.api.nvim_win_set_height(window.winid, each_height)
  end
end

M.add_window_to_stack = function(bufnr)
  local last_window = stack[#stack]
  if not last_window or not vim.api.nvim_win_is_valid(last_window.winid) then
    M.create_window(bufnr, "botright vertical", get_size())
    return
  end
  vim.api.nvim_set_current_win(last_window.winid)
  M.create_window(bufnr, "belowright")
  M.resize_windows_on_stack()
end

local function get_position_on_stack(bufnr)
  for ind, window in ipairs(stack) do
    if window.bufnr == bufnr then return ind end
  end
end

M.get_winid = function(bufnr)
  local window = stack[get_position_on_stack(bufnr)]
  if window then return window.winid end
end

M.create_window = function(bufnr, modifier, size)
  if size == nil
    then size = ""
  elseif type(size) == "function"
    then size = size()
  end

  local cmd = "split"
  if modifier ~= "" then
    cmd = modifier .. " " .. size .. cmd
  end
  vim.cmd(cmd)

  local winid = vim.api.nvim_get_current_win()
  table.insert(stack, {
    winid = winid,
    bufnr = bufnr,
  })
  vim.wo[winid].winfixwidth = true
  vim.wo[winid].winfixheight = true

  vim.api.nvim_create_autocmd("WinClosed", {
    group = augroup,
    pattern = tostring(winid),
    callback = function()
      table.remove(stack, get_position_on_stack(bufnr))
      vim.schedule(M.resize_windows_on_stack)
      return true
    end
  })
end

M.close_window = function(bufnr)
  local winid = M.get_winid(bufnr)
  if not winid then
    return false
  end

  if not vim.api.nvim_win_is_valid(winid) then
    return false
  end

  vim.api.nvim_win_close(winid, false)
end

return M
