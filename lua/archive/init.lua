local M = {}

local config = require("archive.config")

---@diagnostic disable-next-line: unused-local
local _ = require("archive.types")

function M.setup(opts)
  vim.filetype.add({
    extension = {
      task = "markdown",
    },
  })

  config.options = vim.tbl_deep_extend("force", {}, config.defaults, opts or {})
  require("archive.search").setup(config.options.search)
  require("archive.task").setup(config.options)
  require("archive.highlight").setup(config.options)
  require("archive.autocmds").setup()
end

M.search = require("archive.search")
M.task = require("archive.task")

return M
