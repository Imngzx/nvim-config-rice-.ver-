local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/folke/flash.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  keys = {
    { { 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash' } },
    { { 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash treesitter' } },
    { 'o', 'r', function() require('flash').remote() end, { desc = 'Remote flash' } },
    { { 'o', 'x' }, 'R', function() require('flash').treesitter_search() end, { desc = 'Treesitter search' } },
    { { 'c' }, '<c-s>', function() require('flash').toggle() end, { desc = 'Toggle flash search' } }
  },
  setup = function() require('flash').setup({}) end
})
