local lazy = require('libs.lazy')

lazy.load({
  plugin = {
    'https://github.com/olimorris/codecompanion.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
  },
  cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionCmd', 'CodeCompanionActions' },
  keys = {
    { 'n', '<leader>ai', function() vim.cmd('CodeCompanionChat Toggle') end, { desc = 'Toggle AI Chat' } },
    { 'v', '<leader>ae', function() vim.cmd('CodeCompanion') end, { desc = 'AI Edit (Selection)' } },
    { 'n', '<leader>ae', function() vim.cmd('CodeCompanion') end, { desc = 'AI Edit (Prompt)' } },
    { 'n', '<leader>ac', function() vim.cmd('CodeCompanionActions') end, { desc = 'AI Actions' } },
    { 'v', '<leader>ac', function() vim.cmd('CodeCompanionActions') end, { desc = 'AI Actions' } },
  },
  setup = function()
    require('codecompanion').setup({
      -- 1. 全局锁定 Gemini
      strategies = {
        chat = { adapter = 'gemini' },
        inline = { adapter = 'gemini' },
      },

      adapters = {
        gemini = function()
          return require('codecompanion.adapters').extend('gemini', {
            env = {
              api_key = 'GEMINI_API_KEY', -- 记得配置环境变量
            },
            schema = {
              model = {
                -- 强行锁定默认使用速度极快且免费的 Flash 模型（推荐最新的 2.0-flash）
                default = 'gemini-3-flash',
                choices = {
                  'gemini-2.0-flash',
                  'gemini-2.0-pro-exp-02-05',
                  'gemini-1.5-flash',
                  'gemini-1.5-pro',
                },
              },
            },
          })
        end,
      },

      display = {
        action_palette = {
          provider = 'snacks', -- 完美联动你酷炫的 Snacks 选择器
        },
        chat = {
          window = { width = 0.4 },
          -- 👇 核心微调：因为你用了 render-markdown，我们要关掉 CodeCompanion
          -- 自带的纯文本分割线，避免 UI 冲突，让 render-markdown 的线接管！
          show_header_separator = false,
        },
      },
    })
  end
})
