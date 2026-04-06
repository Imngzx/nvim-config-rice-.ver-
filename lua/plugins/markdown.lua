local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown', 'norg', 'rmd', 'org', 'codecompanion' },
  setup = function()
    vim.pack.add({ 'https://github.com/nvim-mini/mini.icons' })

    require('render-markdown').setup({
      file_types = { 'markdown', 'norg', 'rmd', 'org', 'codecompanion' },

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

    vim.schedule(function()
      vim.cmd('doautocmd FileType ' .. vim.bo.filetype)
    end)

    local ok, snacks = pcall(require, 'snacks')
    if ok then
      snacks.toggle({
        name = 'Render Markdown',
        get = function()
          return require('render-markdown.state').enabled
        end,
        set = function(enabled)
          local m = require('render-markdown')
          if enabled then
            m.enable()
          else
            m.disable()
          end
        end,
      }):map('<leader>um')
    end
  end
})
