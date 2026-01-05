--- TASK(20251218-071242): Add README.md

local M = {}

local config = require("archive.config")

---@diagnostic disable-next-line: unused-local
local _ = require("archive.types")

function M.setup(opts)
  config.options = vim.tbl_deep_extend("force", {}, config.defaults, opts or {})
  require("archive.search").setup(config.options.search)
  require("archive.task").setup(config.options)
  require("archive.highlight").setup(config.options)
  require("archive.autocmds").setup()

  if Snacks and pcall(require, "snacks.picker") then
    Snacks.picker.sources.task = require("archive.snacks.task").source
    Snacks.picker.task_storage = function(picker_opts)
      return require("archive.snacks.task_storage").task_storage(picker_opts)
    end
  end
end

M.search = require("archive.search")
M.task = require("archive.task")
M.win = require("archive.win")

return M
