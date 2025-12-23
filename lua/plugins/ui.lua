-- [Cursor]
vim.pack.add({ 'https://github.com/sphamba/smear-cursor.nvim' })
require('smear_cursor').setup({
  smear_between_buffers = true,
})

-- [Icon]
vim.pack.add({ 'https://github.com/nvim-mini/mini.icons' })
require('mini.icons').setup()
