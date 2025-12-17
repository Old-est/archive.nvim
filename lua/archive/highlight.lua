local M = {}

---@param opts archive.Options
function M.setup(opts)
  M.main_ns = vim.api.nvim_create_namespace("archive.main")
  M.virtual_lines_ns = vim.api.nvim_create_namespace("archive.virt_lines")
  M.colors = opts.task.colors

  vim.api.nvim_set_hl(0, "TaskStatus", M.colors.status)
  vim.api.nvim_set_hl(0, "Task", M.colors.task)
  vim.api.nvim_set_hl(0, "TaskDesc", M.colors.desc)
end

function M.highlight_task(buf)
  local Task = require("archive.task")
  vim.api.nvim_buf_clear_namespace(buf, M.main_ns, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for row, line in ipairs(lines) do
    if Task.is_task(line) then
      local start_task, end_desc, start_desc = Task.get_task_idxs(line)

      vim.api.nvim_buf_set_extmark(buf, M.main_ns, row - 1, start_task - 1, {
        end_col = start_desc - 1,
        hl_group = "Task",
      })

      vim.api.nvim_buf_set_extmark(buf, M.main_ns, row - 1, start_desc - 1, {
        end_col = end_desc,
        hl_group = "TaskDesc",
      })
    end
  end
end

function M.statistics_virtual_lines(buf)
  local Task = require("archive.task")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_buf_clear_namespace(buf, M.virtual_lines_ns, 0, -1)

  local cursor = vim.api.nvim_win_get_cursor(win)
  local current_line = cursor[1] - 1 -- 0-based
  local line = vim.api.nvim_buf_get_lines(buf, current_line, current_line + 1, false)[1]
  if not line or line == "" then
    return
  end

  local task = Task.create_from_line(line)
  if task then
    local data_virt = task:generate_virt_lines()
    vim.api.nvim_buf_set_extmark(buf, M.virtual_lines_ns, current_line, -1, {
      virt_lines = data_virt,
    })
  end
end

return M
