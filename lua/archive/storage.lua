---@class archive.Storage
local M = {}

---@param task archive.Task
function M.dump_to_storage(task)
  local storage = require("archive.config").options
  local utils = require("archive.utils")
  if storage.storage_name == "" then
    utils.error("Empty storage_name opt")
    return
  end

  if next(storage.root_markers) == nil then
    utils.error("Empty root_markers")
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(buf)
  local root_dir = utils.find_root(storage.root_markers, path ~= "" and path or vim.loop.cwd())

  if not root_dir then
    root_dir = vim.loop.cwd()
  end

  print(root_dir)

  if utils.has_dir(root_dir, storage.storage_name) == 0 then
    utils.error("There is no storage dir in project")
    return
  end

  local file_name = string.format("%s.task", os.date("!%Y%m%d-%H%M%S", task.creation_time))
  local file_path = vim.fs.joinpath(root_dir, storage.storage_name, file_name)
  local content = task:create_form()

  vim.fn.mkdir(vim.fn.fnamemodify(file_path, ":h"), "p")
  local file = io.open(file_path, "w")
  assert(file, "Cant create file")
  file:write(content)
  file:close()
  return file_path
end

return M
