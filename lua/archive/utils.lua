---@class archive.Utils
local M = {}

---@param path string Path to possible task file
---@return boolean Check result
function M.is_task_file(path)
  return vim.fn.fnamemodify(path, ":e") == "task"
end

---@param pattern string
---@param path string
function M.find_pattern(pattern, path, cb)
  local search = require("archive.config").options.search
  local command = { search.command }
  vim.list_extend(command, search.args)
  table.insert(command, pattern)
  table.insert(command, path)

  vim.system(command, { text = true }, function(res)
    if res.code ~= 0 and res.code ~= 1 then
      return cb({})
    end

    local items = {}

    for _, line in pairs(vim.split(res.stdout or "", "\n")) do
      if line ~= "" then
        table.insert(items, line)
      end
    end
    cb(items)
  end)
end

function M.warn(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "Archive" })
end

function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "Archive" })
end

function M.find_root(root_markers, start_path)
  local found = vim.fs.find(root_markers, {
    path = start_path,
    upward = true,
    stop = vim.loop.os_homedir(),
  })[1]

  if not found then
    return nil
  end

  return vim.fs.dirname(found)
end

function M.get_root_from_current(root_markers)
  local buf = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(buf)
  local root_dir = M.find_root(root_markers, path ~= "" and path or vim.loop.cwd())

  if not root_dir then
    root_dir = vim.loop.cwd()
  end
  return root_dir
end

function M.has_dir(root_dir, name)
  local path = vim.fs.joinpath(root_dir, name)
  return vim.fn.isdirectory(path)
end

function M.read_file_lines(path)
  local lines = {}
  local f = io.open(path, "r")
  if not f then
    return lines
  end -- если файла нет
  for line in f:lines() do
    table.insert(lines, line)
  end
  f:close()
  return lines
end

function M.table_to_string(t)
  local parts = {}
  for k, v in pairs(t) do
    table.insert(parts, k .. "=" .. tostring(v))
  end
  return "{" .. table.concat(parts, ", ") .. "}"
end

return M
