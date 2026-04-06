local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/nvim-mini/mini.icons',
  event = { 'User', pattern = 'VeryLazy' },
  setup = function()
    require('mini.icons').setup()
    require('mini.icons').mock_nvim_web_devicons()
  end
})

lazy.load({
  plugin = 'https://github.com/bekaboo/dropbar.nvim',
  event = { 'User', pattern = 'VeryLazy' },
  setup = function()
    local dropbar_api = require('dropbar.api')

    vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
    vim.keymap.set('n', '[;', dropbar_api.goto_context_start,
      { desc = 'Go to start of current context' })
    vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
  end,
})
