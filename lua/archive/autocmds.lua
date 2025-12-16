local M = {}

local Task = require("archive.task")
local opts = require("archive.config")
local utils = require("archive.utils")

local function parse_rg_tags(rg_lines)
  local tags = {}
  for _, line in ipairs(rg_lines) do
    -- Разделяем на путь, line, col и остаток
    local content = line:match("^[^:]+:%d+:%d+:(.*)$")
    if content then
      -- Парсим тег и значение
      local key, value = content:match("^%s*[-#]*%s*(.-)%s*:%s*(.*)$")
      if key and value then
        tags[key] = value
      end
    end
  end
  return tags
end

M._task_add_virtual_text = function(buf, row, tags, hl)
  vim.api.nvim_buf_set_extmark(buf, opts.ns, row, 0, {
    virt_text = { { utils.table_to_string(tags), hl } },
    virt_text_pos = "eol",
  })
end

function M._decorate_tasks(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, opts.ns, 0, -1) -- очищаем старый vt
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    local task = Task.new_from_task_line(line)
    if task then
      local root_path = utils.get_root_from_current(opts.options.root_markers)
      if utils.has_dir(root_path, opts.options.storage_name) ~= 0 then
        local path_to_task = vim.fs.joinpath(root_path, opts.options.storage_name, task.task_name .. ".task")

        local tag = [[\s*(STATUS|OPEN\ DATE\ \(UTC\)|PRIORITY):]]
        utils.find_pattern(tag, path_to_task, function(res)
          if res then
            vim.schedule(function()
              M._task_add_virtual_text(buf, i - 1, parse_rg_tags(res), "TaskStatus")
            end)
          end
        end)
      end
    end
  end
end

M.setup_autocmds = function()
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "TextChanged" }, {
    pattern = "*", -- можно любой filetype или "*"
    callback = function()
      M._decorate_tasks()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "TextChanged", "TextChangedI" }, {
    pattern = "*",
    callback = function(args)
      local buf = args.buf
      -- очищаем старую подсветку
      vim.api.nvim_buf_clear_namespace(buf, 0, 0, -1)
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      for row, line in ipairs(lines) do
        local start_col, task_id, desc_start, desc, e =
          line:match("()TASK%((%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d)%)%s*:%s*()(.+)()")
        if start_col then
          local end_col_task = start_col + #("TASK(" .. task_id .. "):") - 1

          vim.api.nvim_buf_set_extmark(buf, opts.ns, row - 1, start_col - 1, {
            end_col = end_col_task,
            hl_group = "Task",
          })

          print(end_col_task)
          print(e)

          vim.api.nvim_buf_set_extmark(buf, opts.ns, row - 1, end_col_task, {
            end_col = e -1,
            hl_group = "TaskDesc",
          })
        end
      end
    end,
  })
end

return M
