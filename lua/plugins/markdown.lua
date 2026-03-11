local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown', 'norg', 'rmd', 'org', 'codecompanion' },
  setup = function()
    -- 👇 修复 2：强行提前加载图标插件，保证渲染时绝对不会崩溃！
    vim.pack.add({ 'https://github.com/nvim-mini/mini.icons' })

    require('render-markdown').setup({
      -- 👇 修复 1：名字必须是 file_types！把 codecompanion 真正加进去
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

    -- 👇 修复 3：填补懒加载的时间差！
    -- 强行告诉 Neovim：“重新触发一下当前文件的事件，让插件立刻给我渲染！”
    vim.schedule(function()
      vim.cmd('doautocmd FileType ' .. vim.bo.filetype)
    end)

    -- Snacks toggle 保持不变
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
