--- @class archive.Config
local M = {}

--- @type archive.Options
M.options = {}

M.ns = vim.api.nvim_create_namespace("archive")

vim.api.nvim_set_hl(0, "TaskStatus", { fg = "#ffd700", bold = true })
vim.api.nvim_set_hl(0, "Task", { fg = "#52796f", bold = true })
vim.api.nvim_set_hl(0, "TaskDesc", { fg = "#9226c7", bold = true })

--- @class archive.Options
local defaults = {
  storage_name = "tasks",

  root_markers = { ".git", ".clangd" },

  task = {
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
    pattern = {
      TODO = "TODO:",
      BUG = "BUG:",
      FIX = "FIX:",
      TASK = [[TASK\(\d{8}-\d{6}\):]],
    },
  },
}

function M.setup(options)
  M.options = options
  M.options = vim.tbl_deep_extend("force", {}, defaults, M.options or {})
  vim.api.nvim_set_hl_ns(M.ns)
  require("archive.autocmds").setup_autocmds()
  require("archive.task").setup(M.options)

  if Snacks and pcall(require, "snacks.picker") then
    Snacks.picker.sources.task = require("archive.snacks").source
  end
  M.loaded = true
end

return M
