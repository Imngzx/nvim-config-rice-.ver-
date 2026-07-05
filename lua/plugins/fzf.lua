local resonance = require('resonance')

resonance.load({
  'https://github.com/ibhagwan/fzf-lua',
  cmd = 'FzfLua',
  keys = {
    { 'n', '<leader><leader>', function() require('fzf-lua').files() end, { desc = 'Fzf Files' } },
    { 'n', '<leader>/', function() require('fzf-lua').live_grep() end, { desc = 'Fzf Live Grep' } },
    { 'n', '<leader>fb', function() require('fzf-lua').buffers() end, { desc = 'Fzf Buffers' } },
  },
  config = function()
    require('fzf-lua').setup({
      'default',
      fzf_colors = true,
      winopts = {
        border = 'rounded',
        preview = {
          border = 'border',
          scrollbar = 'float',
        },
      },
      keymap = {
        builtin = {
          ['<Esc>'] = 'hide',
        },
        fzf = {
          ['esc'] = 'abort',
        }
      }
    })
  end
}
)
