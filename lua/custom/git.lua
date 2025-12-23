local function float_window(execution)
  local w, h = math.floor(vim.o.columns * 0.8), math.floor(vim.o.lines * 0.8)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = w,
    height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = 'minimal',
    border = 'single',
  })
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.fn.termopen(execution)
  vim.cmd('startinsert')

  -- Close mapping (terminal and normal mode)
  vim.keymap.set('t', 'q', '<C-\\><C-n>:bd!<CR>', { silent = true })
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>:bd!<CR>', { silent = true })
  vim.keymap.set('n', 'q', ':bd!<CR>', { buffer = buf, silent = true })
end

vim.keymap.set('n', '<leader>gg', function() float_window('lazygit') end, { desc = "Open lazygit", noremap = true })
vim.keymap.set('n', '<leader>gj', function() float_window('jjui') end, { desc = "Open jjui", noremap = true })
