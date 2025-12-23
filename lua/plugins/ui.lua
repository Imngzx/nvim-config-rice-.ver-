local lazy = require('libs.lazy')

-- [Cursor]
lazy.on_event({ 'User', pattern = 'VeryLazy' },
  'https://github.com/sphamba/smear-cursor.nvim',
  function()
    require('smear_cursor').setup({
      smear_between_buffers = true,
    })
  end) -- run after 100ms

-- [Icon]
vim.pack.add({ 'https://github.com/nvim-mini/mini.icons' })
require('mini.icons').setup()
