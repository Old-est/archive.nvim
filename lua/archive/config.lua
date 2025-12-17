---@class archive.config
local M = {}

---@param task archive.Task
function M.get_priority(task)
  local map = {
    TODO = 30,
    BUG = 50,
    FIX = 40,
    PERF = 20,
  }
  if map[task.source] then
    return map[task.source]
  else
    return 10
  end
end

---@param task archive.Task
function M.get_creation_time(task)
  return os.date("!%Y/%m/%d %H:%M:%S", task.creation_time)
end

---@param task archive.Task
function M.get_type(task)
  return task.source
end

---@type archive.Options
M.defaults = {
  storage = "tasks",

  task = {
    colors = {
      status = { fg = "#ffd700", bg = "none", bold = true },
      task = { fg = "#52796f", bg = "none", bold = true },
      desc = { fg = "#ffd700", bg = "none", bold = true },
    },

    tags = {
      type = { name = "TYPE", default_value = M.get_type },
      status = { name = "STATUS", values = { "OPEN", "DONE", "INPROGRESS", "PAUSED" }, default_value = "OPEN" },
      priority = { name = "PRIORITY", default_value = M.get_priority },
      creation_date = { name = "OPEN DATE (UTC)", default_value = M.get_creation_time },
      close_date = { name = "CLOSE DATE (UTC)" },
    },

    tags_order = { "type", "status", "priority", "creation_date", "close_date" },

    status = {
      "OPEN",
      "DONE",
      "INPROGRESS",
      "PAUSED",
    },

    default_status = "OPEN",

    source = {
      TODO = { priority = 30 },
      BUG = { priority = 50 },
      FIX = { priority = 40 },
    },
  },

  search = {
    command = "rg",
    args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" },
    root_markers = { ".git", "stylua.toml" },
  },
}

---@type archive.Options
M.options = vim.deepcopy(M.defaults)

return M
