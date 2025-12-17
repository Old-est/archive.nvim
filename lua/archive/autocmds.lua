local M = {}

function M.setup()
  vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost", "BufNewFile", "TextChanged", "TextChangedI" }, {
    group = vim.api.nvim_create_augroup("TaskHighlight", { clear = true }),
    pattern = "*",
    callback = function(ev)
      local buf = ev.buf
      require("archive.highlight").highlight_task(buf)
    end,
  })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = vim.api.nvim_create_augroup("TaskHoverVirtLines", { clear = true }),
    callback = function(ev)
      vim.schedule(function()
        require("archive.highlight").statistics_virtual_lines(ev.buf)
      end)
    end,
  })
end

return M
