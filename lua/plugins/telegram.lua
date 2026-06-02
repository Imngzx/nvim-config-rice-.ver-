local resonance = require('resonance')

resonance.load({
  plugin = {
    src = 'https://github.com/ChuYanLon/telegram.nvim',
    version = 'main',
    build = 'npm i'
  },

  cmd = { 'Tg', 'TgLogout', 'TgSend', 'TgPr' },
  keys = {
    { 'n', '<leader>Tg', '<cmd>Tg<CR>', { desc = 'Open Telegram' } },
    { 'n', '<leader>TL', '<cmd>TgLogout<CR>', { desc = 'Logout Telegram' } },
  },
  setup = function()
    require('telegram').setup({})
  end
})
