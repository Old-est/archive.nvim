local M = {}

local config = require("archive.config")

---@class snacks.picker.task_storage.Config: snacks.picker.files.Config
M.source = {
  -- Наследуем от files, добавляем свои defaults
  ft = { "md" }, -- лучше как таблица, если snacks ожидает массив
  dirs = { vim.fs.joinpath(require("archive.search").get_root_from_current(), config.options.storage) },
  hidden = true,
  ignored = false, -- ты имел true, но для storage обычно false, чтобы .git не лез
  -- любые другие overrides: layout, win, finder и т.д.
  -- например:
  -- layout = { preset = "vertical" },
  -- win = { preview = { enabled = true } },
}

--- Запуск пикера
---@param opts? snacks.picker.task_storage.Config
function M.task_storage(opts)
  opts = opts or {}
  local options = vim.tbl_deep_extend("force", {}, M.source, opts)
  -- "files" — это базовый source, на котором строится твой
  return Snacks.picker.files(options)
end

return M
