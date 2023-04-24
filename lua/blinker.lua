local ns = vim.api.nvim_create_namespace("")
local initialized = false
local options = nil
local defaults = {count = 2, duration = 100, color = "white", highlight = "BlinkingLine"}
local function insert_highlights()
  return vim.api.nvim_set_hl(0, "BlinkingLine", {bg = options.color})
end
local function blink_cursorline()
  if initialized then
    local winwidth = vim.api.nvim_win_get_width(0)
    local start = vim.api.nvim_win_get_cursor(0)
    local startx = (start[1] - 1)
    local on_fn
    local function _1_()
      if vim.api.nvim_buf_is_valid(0) then
        return vim.api.nvim_buf_add_highlight(0, ns, options.highlight, startx, 0, -1)
      else
        return nil
      end
    end
    on_fn = _1_
    local off_fn
    local function _3_()
      if vim.api.nvim_buf_is_valid(0) then
        return vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
      else
        return nil
      end
    end
    off_fn = _3_
    on_fn()
    vim.defer_fn(off_fn, options.duration)
    for i = 2, (2 * (options.count - 1)), 2 do
      local delay1 = (i * options.duration)
      local delay2 = (delay1 + options.duration)
      vim.defer_fn(on_fn, delay1)
      vim.defer_fn(off_fn, delay2)
    end
    return nil
  else
    return vim.notify("blinker.nvim is not initialized. Call the setup function")
  end
end
local function setup(opts)
  options = vim.tbl_deep_extend("force", {}, defaults, opts)
  insert_highlights()
  local function _6_()
    return insert_highlights()
  end
  vim.api.nvim_create_autocmd("ColorScheme", {group = vim.api.nvim_create_augroup("BlinkerInitHighlight", {clear = true}), callback = _6_})
  initialized = true
  return nil
end
return {setup = setup, blink_cursorline = blink_cursorline, insert_highlights = insert_highlights, options = options}
