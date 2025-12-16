---@class archive
local M = {}

local Task = require("archive.task")

M.setup = require("archive.config").setup

vim.filetype.add({
  extension = {
    task = "markdown",
  },
})

M.find_tasks_buffer = function()
  local buf = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(buf)

  local task = require("archive.task")
  task.find_tasks(path)
end

M.create_task = function()
  local current_line = vim.api.nvim_get_current_line()

  local new_task = Task.new_from_line(current_line)
  local file_path = require("archive.storage").dump_to_storage(new_task)
  if file_path then
    local buf = vim.api.nvim_get_current_buf() -- текущий буфер
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local task_string = new_task:format()
    local prefix = current_line:match("^(.-)TODO:")
    vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { prefix .. task_string })
    vim.cmd("split " .. vim.fn.fnameescape(file_path))
  end
end

M.go_to_task = Task.go_to_task

return M
