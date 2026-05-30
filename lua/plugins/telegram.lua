local resonance = require('resonance')

resonance.load({
  plugin = {
    'https://github.com/MunifTanjim/nui.nvim',
    {
      src = 'https://github.com/ChuYanLon/telegram.nvim',
      version = 'main',
      build = 'npm i'
    },
  },


  cmd = { 'Tg', 'TgLogout', 'TgSend', 'TgPr' },
  keys = {
    { 'n', '<leader>tt', '<cmd>Tg<CR>', { desc = 'Open Telegram' } },
    { 'n', '<leader>tL', '<cmd>TgLogout<CR>', { desc = 'Logout Telegram' } },
  },
  setup = function()
    require('telegram').setup({})
  end
})
