---@class archive.search
local M = {}

local Utils = require("archive.utils")

---@type archive.SearchConfig
M.opts = nil

---@param opts archive.SearchConfig
function M.setup(opts)
  M.opts = opts
end

---@param line string
---@return archive.SearchRgResult | nil
local function parse_line(line)
  local filename, lnum, col, text = line:match("([^:]+):(%d+):(%d+):(.*)")
  if not filename then
    return nil
  end
  return {
    filename = filename,
    lnum = tonumber(lnum),
    col = tonumber(col),
    text = text,
  }
end

---@param pattern string Pattern to search
---@param path string Path from which search begins (if dir means recursive)
---@return archive.SearchRgResult[]
function M.search_pattern_sync(pattern, path)
  local command = { M.opts.command }
  vim.list_extend(command, M.opts.args)
  table.insert(command, pattern)
  table.insert(command, path)
  local result = {}
  local handle = Utils.system(command, function(items)
    for _, line in ipairs(items or {}) do
      local parsed = parse_line(line)
      if parsed then
        table.insert(result, parsed)
      end
    end
  end)
  handle:wait()
  return result
end

function M.get_root_from_current()
   return Utils.get_root_from_current(M.opts.root_markers) 
end

return M
