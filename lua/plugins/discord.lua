local resonance = require('resonance')

resonance.load({
  plugin = {
    {
      src = 'https://github.com/vyfor/cord.nvim',
    }
  },

  event = { 'User', pattern = 'VeryLazy' },

  setup = function()
    require('cord').setup({})
  end
})
