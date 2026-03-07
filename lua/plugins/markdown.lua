local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/MeanderingProgrammer/render-markdown.nvim',

  -- event = { 'BufReadPost', 'BufNewFile' },
  event = { 'User', pattern = 'VeryLazy' },

  setup = function()
    require('render-markdown').setup({
      ---@module 'render-markdown'
      ft = { 'markdown', 'norg', 'rmd', 'org', 'codecompanion' },
      code = {
        sign = true,
        width = 'block',
        right_pad = 1,
      },
      heading = {
        sign = true,
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        width = 'block',
        left_pad = 2,
        right_pad = 4,
      },
      checkbox = {
        enabled = true,
      },
      quote = {
        enabled = true,
      },

      latex = {
        enabled = true,
        render_modes = false,
        converter = { 'utftex', 'latex2text' },
        highlight = 'RenderMarkdownMath',
        position = 'center',
        top_pad = 0,
        bottom_pad = 0,
      },
      completions = { lsp = { enabled = false } },

    })
  end

})
