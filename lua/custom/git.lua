local function float_lazygit()
  local w, h = math.floor(vim.o.columns * 0.8), math.floor(vim.o.lines * 0.8)
  local buf = vim.api.nvim_create_buf(false, true)
  api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = w,
    height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = 'minimal',
    border = 'rounded'
  })
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.fn.termopen('lazygit')
  vim.cmd('startinsert')
  -- Close mapping (terminal and normal mode)
  vim.keymap.set('t', 'q', '<C-\\><C-n>:bd!<CR>', { silent = true })
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>:bd!<CR>', { silent = true })
  vim.keymap.set('n', 'q', ':bd!<CR>', { buffer = buf, silent = true })
end

vim.keymap.set('n', '<leader>gg', float_lazygit, { desc = "Open lazygit", noremap = true })
