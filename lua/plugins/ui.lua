require('resonance').load({
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
    'https://github.com/Imngzx/showkeys',
    cmd = { 'ShowkeysToggle' },
    config = function()
      require('showkeys').setup({
        position = 'bottom-center',
        maxkeys = 5
      })
    end
  }
})
