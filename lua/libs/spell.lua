local M = {}

M.setup = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local vim_o_local = vim.opt_local

  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_call(bufnr, function()
        vim_o_local.spell = true
        vim_o_local.spelllang = { 'en_us', 'ms', 'cjk', 'id' }
      end)
    end
  end)
end

return M
