-- [Theme]
-- vim.pack.add({ 'https://github.com/projekt0n/github-nvim-theme' })
-- require('github-theme').setup()
-- vim.cmd('colorscheme github_dark')

-- [Cursor]
vim.pack.add({ 'https://github.com/sphamba/smear-cursor.nvim' })
require('smear_cursor').setup({
  smear_between_buffers = true,
})

-- [Icon]
vim.pack.add({ 'https://github.com/nvim-mini/mini.icons' })
require('mini.icons').setup()
