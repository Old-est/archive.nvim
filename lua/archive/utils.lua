---@class archive.utils
local M = {}

--- Run a system command asynchronously and return output lines via callback
---@param cmd string[] Command to run
---@param cb fun(items: string[]) Callback receiving array of lines
---@return vim.SystemObj run handle returned by vim.system
function M.system(cmd, cb)
  local run = vim.system(cmd, { text = true }, function(res)
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
  return run
end

--- Set window-local options.
---@param win number
---@param wo vim.wo|{}|{winhighlight: string|table<string, string>}
function M.wo(win, wo)
  for k, v in pairs(wo or {}) do
    if k == "winhighlight" and type(v) == "table" then
      local parts = {} ---@type string[]
      for kk, vv in pairs(v) do
        if vv ~= "" then
          parts[#parts + 1] = ("%s:%s"):format(kk, vv)
        end
      end
      v = table.concat(parts, ",")
    end
    vim.api.nvim_set_option_value(k, v, { scope = "local", win = win })
  end
end

---@param root_markers string[]
---@param start_path string
---@return string|nil
function M.get_root(root_markers, start_path)
  local found = vim.fs.find(root_markers, { path = start_path, upward = true, stop = vim.loop.os_homedir() })[1]

  if not found then
    return nil
  end

  return vim.fs.dirname(found)
end

---@param root_markers string[]
---@return string
function M.get_root_from_current(root_markers)
  local buf = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(buf)
  local root_dir = M.get_root(root_markers, path ~= "" and path or vim.loop.cwd())

  if not root_dir then
    root_dir = vim.loop.cwd()
  end
  return root_dir
end

function M.make_rg_or(tags)
  local escaped_tags = {}
  for _, tag in ipairs(tags) do
    -- экранируем пробелы и спецсимволы: (), ., +, *, ?, [, ], ^, $, | и пробел
    local escaped = tag:gsub("([ ()%.%+%-%*%?%[%]%^%$|])", "\\%1")
    table.insert(escaped_tags, escaped)
  end
  -- объединяем через | и добавляем пробелы перед и двоеточие после
  local pattern = "\\s*(" .. table.concat(escaped_tags, "|") .. "):"
  return pattern
end

function M.get_tag_names(tags_table)
  local names = {}
  for _, tag in pairs(tags_table) do
    if tag.name then
      table.insert(names, tag.name)
    end
  end
  return names
end

return M
