local resonance = require('resonance')

resonance.load({
  plugin = 'https://github.com/Imngzx/jisho.nvim',

  cmd = { 'Jisho' },

  keys = {
    { 'n', '<leader>tj', function() require('jisho').search() end, { desc = 'Jisho (Word under cursor)' } },
    { 'v', '<leader>tj', function()
      local start_pos = vim.fn.getpos('v')
      local end_pos = vim.fn.getpos('.')
      local lines = vim.fn.getregion(start_pos, end_pos)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
      require('jisho').search(table.concat(lines, ' '))
    end, { desc = 'Jisho (Selection)' } },
  },

  setup = function()
    require('jisho').setup({
      use_budoux = true,
      layout = 'spacious',
    })
  end,
})
