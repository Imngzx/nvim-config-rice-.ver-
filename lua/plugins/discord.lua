local resonance = require('resonance')

resonance.load({
  'https://github.com/vyfor/cord.nvim',

  build = function()
    vim.cmd('Cord update build')
  end,

  event = { 'User', pattern = 'VeryLazy' },

  config = function()
    require('cord').setup({})
  end
})
