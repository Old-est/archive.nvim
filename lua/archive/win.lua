---@class archive.Win
local Win = {}
Win.__index = Win

local Utils = require("archive.utils")

--- TASK(20251218-113557): Add good windows support

function Win.spawn_float_window(buf, opts)
  local win = vim.api.nvim_open_win(buf, true, opts)

  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<Cmd>close<CR>", { silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<Cmd>close<CR>", { silent = true })
  return win
end

function Win.create_buffer(text, opts)
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)

  vim.bo[buf].modifiable = opts.modifiable
  vim.bo[buf].bufhidden = opts.bufhidden
  vim.bo[buf].filetype = opts.filetype
  return buf
end

function Win.get_place(data)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1 -- 0-based
  local col = cursor[2]

  local width = math.min(80, vim.o.columns - 10)
  local height = math.min(#data + 2, math.floor(vim.o.lines * 0.6))

  local anchor = "NW"
  local win_row = 1 -- смещение от курсора
  local win_col = 1

  -- проверяем, поместится ли справа
  if col + width > vim.o.columns then
    win_col = -(width + 1) -- смещаем влево от курсора
    anchor = "NE"
  else
    win_col = 1
  end

  -- проверяем, поместится ли снизу
  if row + height > vim.o.lines then
    win_row = -(height + 1) -- поднимаем окно выше курсора
  else
    win_row = 1
  end

  local win_opts = {
    relative = "cursor",
    row = win_row,
    col = win_col,
    width = width,
    height = height,
    anchor = anchor,
    style = "minimal",
  }
  return win_opts
end

function Win.open_file(path, line, col)
  local bufnr = vim.fn.bufnr(path)

  if bufnr == -1 then
    vim.cmd("edit " .. vim.fn.fnameescape(path))
    bufnr = vim.api.nvim_get_current_buf()
  else
    -- Переключаемся на существующий буфер
    vim.api.nvim_set_current_buf(bufnr)
  end

  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end

  vim.api.nvim_win_set_cursor(0, { line, col })
end

return Win
