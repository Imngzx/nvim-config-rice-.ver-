local api = vim.api

local function open_lazygit()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- New special buffer and window
  local buf = api.nvim_create_buf(false, true)
  local win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
  })

  local term_chan = vim.fn.termopen('lazygit', { detach = 0 })
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.fn.chansend(term_chan, '') -- ensure channel exists
  api.nvim_command('startinsert')

  -- Keymaps to close the window
  api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true })
  api.nvim_buf_set_keymap(buf, 't', '<Esc><Esc>', '<C-\\><C-n><cmd>bd!<CR>', { noremap = true, silent = true })
  api.nvim_buf_set_keymap(buf, 't', 'q', '<C-\\><C-n><cmd>bd!<CR>', { noremap = true, silent = true })
end

-- Keymap to open lazygit
vim.keymap.set('n', '<leader>gg', open_lazygit, { desc = "Open lazygit", noremap = true })
