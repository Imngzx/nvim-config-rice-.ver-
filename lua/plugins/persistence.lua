local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/folke/persistence.nvim',
  event = { 'BufReadPre' },
  cmd = { 'RestoreSession', 'RestoreLastSession', 'StopSession' },
  setup = function()
    local p = require('persistence')
    p.setup({
      options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp' },
      dir = vim.fn.stdpath('state') .. '/sessions/',
    })

    vim.api.nvim_create_user_command('RestoreSession', function() p.load() end, {})
    vim.api.nvim_create_user_command('RestoreLastSession', function() p.load({ last = true }) end, {})
    vim.api.nvim_create_user_command('StopSession', function() p.stop() end, {})
  end
})

vim.keymap.set('n', '<leader>qs', '<cmd>RestoreSession<cr>', { desc = 'Restore Session' })
vim.keymap.set('n', '<leader>ql', '<cmd>RestoreLastSession<cr>', { desc = 'Restore Last Session' })
vim.keymap.set('n', '<leader>qd', '<cmd>StopSession<cr>', { desc = "Don't Save Current Session" })
