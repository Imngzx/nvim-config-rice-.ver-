local lazy = require('libs.lazy')

-- [Cursor]
lazy.load({
  plugin = 'https://github.com/sphamba/smear-cursor.nvim',
  event = { 'User', pattern = 'VeryLazy' },
  setup = function()
    require('smear_cursor').setup({
      smear_between_buffers = true,
    })
  end
})

-- [Icon]
vim.pack.add({ 'https://github.com/nvim-mini/mini.icons' })
require('mini.icons').setup()

-- [Sticky scroll]
lazy.load({
  plugin = 'https://github.com/nvim-treesitter/nvim-treesitter-context',
  event = { 'BufReadPost', 'BufNewFile' },
  setup = function()
    require('treesitter-context').setup({
      max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
      mode = 'topline', -- Line used to calculate context. Choices: 'cursor', 'topline'
    })
  end
})
