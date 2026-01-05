local M = {}

local Config = require("archive.config")
local Task = require("archive.task")

--- TODO:

---@class snacks.picker.task.Config: snacks.picker.grep.Config

---@module 'snacks'
---@type snacks.picker.task.Config|{}
M.source = {
  finder = "grep",
  live = false,
  supports_live = true,
  search = function(picker)
    local opts = picker.opts
    return "TASK\\(\\d{8}-\\d{6}\\)"
  end,
  ---@param item snacks.picker.Item
  ---@param picker snacks.Picker
  format = function(item, picker)
    local a = Snacks.picker.util.align
    local task = Task.create_from_line(item.text)
    local ret = {} ---@type snacks.picker.Highlight
    local icon = Config.options.task.icon
    ret[#ret + 1] = { a(icon, 2), "Task" }
    ret[#ret + 1] = { a("TASK: " .. task.task_name, 6, { align = "center" }), "Task" }
    ret[#ret + 1] = { " " }

    return Snacks.picker.highlight.extend(ret, Snacks.picker.format.file(item, picker))
  end,
}

---@param opts snacks.picker.task.Config
function M.pick(opts)
  return Snacks.picker.pick("task", opts)
end

return M
