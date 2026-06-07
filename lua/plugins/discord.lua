local resonance = require('resonance')

resonance.load({
  'https://github.com/vyfor/cord.nvim',

  event = { 'User', pattern = 'VeryLazy' },

  config = function()
    require('cord').setup({})
  end
})
