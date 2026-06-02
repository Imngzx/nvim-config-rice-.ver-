local resonance = require('resonance')

resonance.load({
  plugin = {
    src = 'https://github.com/ChuYanLon/telegram.nvim',
    version = 'main',
    build = 'npm i'
  },

  cmd = { 'Tg', 'TgLogout', 'TgSend', 'TgPr' },
  keys = {
    { 'n', '<leader>Tp', '<cmd>Tg<CR>', { desc = 'Open Telegram' } },
    { 'n', '<leader>Tl', '<cmd>TgLogout<CR>', { desc = 'Logout Telegram' } },
  },
  setup = function()
    require('telegram').setup({})
  end
})
