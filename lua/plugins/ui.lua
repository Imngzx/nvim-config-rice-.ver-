local resonance = require('resonance')

resonance.load({
  {
    'https://github.com/nvim-mini/mini.icons',
    event = { 'User', pattern = 'VeryLazy' },
    config = function()
      local mini_icons = require('mini.icons')

      mini_icons.setup()
      mini_icons.mock_nvim_web_devicons()
    end
  },

  {
    'https://github.com/bekaboo/dropbar.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('dropbar').setup({
        bar = {
          update_events = {
            buf = { 'FileChangedShellPost', 'TextChanged', 'ModeChanged' }
          }
        }
      })

      local dropbar_api = require('dropbar.api')

      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start,
        { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end,
  },
})
