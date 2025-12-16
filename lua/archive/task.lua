---@class archive.Task
---@field task_name string
---@field desc string
---@field type string
---@field status string
---@field priority integer
---@field creation_time integer
local Task = {}
Task.__index = Task

local config
local utils = require("archive.utils")

function Task.setup(opts)
  config = opts
end

---@param line string
---@return archive.Task | nil
function Task.new_from_line(line)
  local self = setmetatable({}, Task)
  local keyword, desc = line:match("^[^A-Z]*([A-Z]+):%s*(.*)")

  if keyword and config.task.source[keyword] then
    self.creation_time = os.time()
    ---@diagnostic disable-next-line: assign-type-mismatch
    self.task_name = os.date("!%Y%m%d-%H%M%S", self.creation_time)
    self.type = keyword
    self.desc = desc
    self.status = config.task.default_status
    self.priority = config.task.source[self.type].priority or 30
    return self
  end
end

---@param line string
---@return archive.Task | nil
function Task.new_from_task_line(line)
  local self = setmetatable({}, Task)

  local prefix, numbers, desc = line:match("^(.-)TASK%(([%d%-]+)%)%s*:%s*(.*)")

  if numbers == nil then
    return
  end

  self.task_name = numbers
  self.desc = desc
  return self
end

---@return string
function Task:format()
  local formatted = string.format("TASK(%s): %s", os.date("!%Y%m%d-%H%M%S", self.creation_time), self.desc)
  return formatted
end

---@return string
function Task:create_form()
  return string.format(
    "# %s\n\n## Statistics:\n\n- STATUS: %s\n- PRIORITY: %d\n- OPEN DATE (UTC): %s\n- CLOSE DATE:\n\n## Description\n\n",
    self.desc,
    self.status,
    self.priority,
    os.date("!%Y/%m/%d %H:%M:%S", self.creation_time)
  )
end

function Task.parse_tags(lines)
  local tags = {}
  for _, line in ipairs(lines) do
    -- ищем формат: KEY: value
    local key, value = line:match("^%s*(%u+)%s*:%s*(.*)")
    if key and value then
      tags[key] = value
    end
  end
  return tags
end

function Task.go_to_task()
  local current_line = vim.api.nvim_get_current_line()

  local task = Task.new_from_task_line(current_line)
  if not task then
    return
  end

  local root_dir = utils.get_root_from_current(config.root_markers)
  if utils.has_dir(root_dir, config.storage_name) ~= 0 then
    local path_to_task = vim.fs.joinpath(root_dir, config.storage_name, task.task_name .. ".task")
    vim.cmd("edit " .. vim.fn.fnameescape(path_to_task))
  end
end

return Task
