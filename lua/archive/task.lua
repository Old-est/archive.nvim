---@class archive.task
local M = {}

--- TASK(20251217-171941): Try to implement coroutines

--- TASK(20251217-175204): Add good hover display support

local uv = vim.uv or vim.loop
local Utils = require("archive.utils")

---@class archive.Task
local Task = {}
Task.__index = Task

---@param tags table<string, archive.TaskTag>
---@return table<string, string>  -- ["OPEN DATE (UTC)"] = "creation_date"
local function build_tag_lookup(tags)
  local map = {}
  for key, tag in pairs(tags) do
    map[tag.name] = key
  end
  return map
end

---@param opts archive.Options
function M.setup(opts)
  M.opts = opts.task
  M.storage = opts.storage
  M.look_up = build_tag_lookup(M.opts.tags)
end

function M.is_task(line)
  local task_name, desc = line:match("TASK%((%d+%-%d+)%)%s*:%s*(.*)")

  if not task_name and not desc then
    return false
  end
  return true
end

function M.is_task_cursor()
  local line = vim.api.nvim_get_current_line()
  return M.is_task(line)
end

---@param line string
---@return archive.Task | nil
function M.create_from_line(line)
  local task_name, desc = line:match("TASK%((%d+%-%d+)%)%s*:%s*(.*)")

  if not task_name then
    return
  end

  local new_task = setmetatable({}, Task)

  --- get_root_dir function
  --- Try to get associated task_file
  local root_dir = require("archive.search").get_root_from_current()
  local task_path = vim.fs.joinpath(root_dir, M.storage, task_name .. ".md")
  if uv.fs_stat(task_path) then
    local tags = Utils.get_tag_names(M.opts.tags)
    local regex = Utils.make_rg_or(tags)

    local search = require("archive.search").search_pattern_sync(regex, task_path)

    ---@type archive.Task
    new_task.task_name = task_name
    new_task.desc = desc
    new_task.stats = {}
    for _, item in pairs(search) do
      local key, value = item.text:match("^%s*%-?%s*([^:]+)%s*:%s*(.*)")
      if key and value then
        if M.look_up[key] then
          new_task.stats[M.look_up[key]] = value
        end
      end
    end
  end
  return new_task
end

function M.create_from_line_cursor()
  local line = vim.api.nvim_get_current_line()
  return M.create_from_line(line)
end

function M.get_task_idxs(line)
  return line:find("TASK%(%d+%-%d+%)%s*:%s*().+$")
end

function M.get_task_idxs_cursor()
  local line = vim.api.nvim_get_current_line()
  return M.get_task_idxs(line)
end

--- Constructs task from list of sources
---@param line string
---@return archive.Task | nil
function M.construct_task(line)
  local self = setmetatable({}, Task)
  local keyword, desc = line:match("^[^A-Z]*([A-Z]+):%s*(.*)")

  if keyword then
    self.creation_time = os.time()
    ---@diagnostic disable-next-line: assign-type-mismatch
    self.task_name = os.date("!%Y%m%d-%H%M%S", self.creation_time)
    self.desc = desc
    self.source = keyword
    self.stats = {}
    for key, tag_info in pairs(M.opts.tags) do
      self.stats[key] = ""
      if tag_info.default_value then
        if type(tag_info.default_value) == "function" then
          self.stats[key] = tag_info.default_value(self)
        else
          ---@diagnostic disable-next-line: assign-type-mismatch
          self.stats[key] = tag_info.default_value
        end
      end
    end
    return self
  end
end

function M.construct_task_cursor()
  local line = vim.api.nvim_get_current_line()
  return M.construct_task(line)
end

---@return string
function Task:construct_task_content()
  local lines = {}

  table.insert(lines, "# " .. self.desc)
  table.insert(lines, "")

  table.insert(lines, "## Statistics:")
  table.insert(lines, "")

  for _, key in pairs(M.opts.tags_order) do
    local display_name = M.opts.tags[key].name
    local tag_info = self.stats[key]
    if tag_info then
      table.insert(lines, "- " .. display_name .. ": " .. tag_info)
    else
      table.insert(lines, "- " .. display_name .. ": ")
    end
  end

  table.insert(lines, "")
  table.insert(lines, "## Description")
  table.insert(lines, "")

  return table.concat(lines, "\n")
end

---@return string
function Task:construct_task_string()
  return string.format("TASK(%s): %s", self.task_name, self.desc)
end

function M.create_task()
  local current_line = vim.api.nvim_get_current_line()
  local buf = vim.api.nvim_get_current_buf() -- текущий буфер
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local task = M.construct_task_cursor()
  if task then
    local form = task:construct_task_content()

    local root_dir = require("archive.search").get_root_from_current()
    local task_path = vim.fs.joinpath(root_dir, M.storage, task.task_name .. ".md")
    local source_dir = vim.fn.fnamemodify(task_path, ":p:h")
    vim.fn.mkdir(source_dir, "p")
    local file = io.open(task_path, "w")
    file:write(form)
    file:close()

    local prefix = current_line:match("^(.-)[A-Z]*:")

    local task_string = task:construct_task_string()

    vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { prefix .. task_string })
    vim.cmd("split " .. vim.fn.fnameescape(task_path))
  end
end

function M.go_to_task()
  local line = vim.api.nvim_get_current_line()
  local task = M.create_from_line(line)

  if task then
    local root_dir = require("archive.search").get_root_from_current()
    local task_path = vim.fs.joinpath(root_dir, M.storage, task.task_name .. ".md")

    if uv.fs_stat(task_path) then
      vim.cmd("edit " .. vim.fn.fnameescape(task_path))
    end
  end
end

function Task:generate_virt_lines()
  local lines = {}

  -- Соберём все строки контента заранее, чтобы посчитать максимальную ширину
  local content_lines = {}

  -- Зафиксируем порядок тегов (обязательно!)
  local ordered_keys = M.opts.tags_order
  local keys = ordered_keys

  local max_width = 0 -- здесь будет максимальная длина строки контента

  for _, key in ipairs(keys) do
    local tag_info = M.opts.tags[key]
    if tag_info then
      local name = tag_info.name or key:upper()
      local raw_value = self.stats[key]

      -- Форматируем значение
      local value
      if raw_value == nil or raw_value == "" then
        value = "-"
      elseif key:match("date") or key:match("time") then
        if type(raw_value) == "number" then
          value = os.date("!%Y/%m/%d %H:%M", raw_value)
        else
          value = tostring(raw_value)
        end
      else
        value = tostring(raw_value)
      end

      -- Строка: " NAME: VALUE"
      local line_text = string.format(" %s: %s", name, value)
      content_lines[#content_lines + 1] = {
        text = line_text,
        full = "│" .. line_text .. " │", -- временно с рамкой, чтобы посчитать длину
        name = name,
        value = value,
        key = key,
      }

      -- Обновляем максимальную ширину (без рамки)
      max_width = math.max(max_width, #line_text)
    end
  end

  -- Минимальная ширина — чтобы не было слишком узко
  local min_width = 30
  max_width = math.max(max_width, min_width)

  -- Теперь строим финальные строки с правильным отступом
  local border = "─"
  local header = "┌─ Task Statistics " .. string.rep(border, max_width - 16) .. "┐"
  local footer = "└" .. string.rep(border, max_width + 2) .. "┘" -- +2 за "│ " и " │"

  table.insert(lines, { { header, "TaskStatus" } })

  for _, item in ipairs(content_lines) do
    -- Вычисляем отступы справа, чтобы всё выровнялось по правому краю
    local padded = item.text .. string.rep(" ", max_width - #item.text)
    local full_line = "│ " .. padded .. " │"

    -- Подсветка (можно кастомизировать по ключу или значению)
    local hl = "TaskStatus"
    table.insert(lines, { { full_line, hl } })
  end

  table.insert(lines, { { footer, "TaskStatus" } })

  return lines
end

return M
