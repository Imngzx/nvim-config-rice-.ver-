local resonance = require('resonance')

resonance.load({
  'https://github.com/ChuYanLon/telegram.nvim',

  build = 'npm i',

  cmd = { 'Tg', 'TgLogout', 'TgSend', 'TgPr' },
  keys = {
    { 'n', '<leader>Tg', '<cmd>Tg<CR>', { desc = 'Open Telegram' } },
    { 'n', '<leader>TL', '<cmd>TgLogout<CR>', { desc = 'Logout Telegram' } },
  },
  config = function()
    require('telegram').setup({})
  end
})
