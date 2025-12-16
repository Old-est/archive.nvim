local Config = require("archive.config")

---@module 'snacks'

local M = {}

---@class snacks.picker.task.Config: snacks.picker.grep.Config

---@type snacks.picker.task.Config
M.source = {
  finder = "grep",
  live = false,
  supports_live = true,
  search = function(picker)
    return ({ Config.options.search.pattern.TASK })[1] -- твой фиксированный паттерн
  end,
  -- Опционально: красивый формат, как в todo-comments
  format = function(item, picker)
    local a = Snacks.picker.util.align
    local ret = {} ---@type snacks.picker.Highlights

    -- Если хочешь выделить ключевое слово (Task) красиво
    local _, _, kw = string.find(item.text, "(Task)")
    if kw then
      ret[#ret + 1] = { a("󰒕", 2), "TodoFgTODO" } -- иконка и цвет
      ret[#ret + 1] = { a("TASK", 6, { align = "center" }), "TodoBgTODO" }
      ret[#ret + 1] = { " " }
    end

    return Snacks.picker.highlight.extend(ret, Snacks.picker.format.file(item, picker))
  end,
  preview = function(ctx)
    Snacks.picker.preview.file(ctx)
    -- Если хочешь подсветку в preview, как в todo-comments:
    -- require("todo-comments.highlight").attach(ctx.preview.win.win, true)
  end,
}

--@param opts snacks.picker.task.Config
function M.pick(opts)
  return Snacks.picker.pick("task", opts)
end

return M
