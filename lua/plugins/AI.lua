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

      -- ──────────────────────────────────────────────────────────────
      --  interactions（原 strategies，v19 起已改名）
      --  在 Chat buffer 内按 `ga` 可以随时切换 adapter 和 model
      -- ──────────────────────────────────────────────────────────────
      interactions = {
        chat = { adapter = 'gemini' }, -- 默认 HTTP adapter
        inline = { adapter = 'gemini' },
        cmd = { adapter = 'gemini' },
      },

      adapters = {

        -- ════════════════════════════════════════════════════════════
        --  HTTP ADAPTERS（直接 API 调用，无需额外 CLI 工具）
        -- ════════════════════════════════════════════════════════════
        http = {

          -- ── Gemini（保留原有，修正模型名） ────────────────────────
          -- 环境变量：export GEMINI_API_KEY=xxx
          gemini = function()
            return require('codecompanion.adapters').extend('gemini', {
              env = {
                api_key = 'GEMINI_API_KEY',
              },
              schema = {
                model = {
                  default = 'gemini-2.5-flash',
                  choices = {
                    'gemini-2.5-pro-preview-03-25',
                    'gemini-2.5-flash',
                    'gemini-2.0-flash',
                    'gemini-2.0-pro-exp-02-05',
                    'gemini-1.5-pro',
                    'gemini-1.5-flash',
                  },
                },
              },
            })
          end,

          -- ── Anthropic Claude（HTTP 直连，最稳定方式） ─────────────
          -- 环境变量：export ANTHROPIC_API_KEY=sk-ant-xxx
          -- 支持 prompt caching，适合长上下文任务
          anthropic = function()
            return require('codecompanion.adapters').extend('anthropic', {
              env = {
                api_key = 'ANTHROPIC_API_KEY',
              },
              schema = {
                model = {
                  default = 'claude-sonnet-4-6', -- 速度与质量最佳平衡
                  choices = {
                    'claude-opus-4-6', -- 最强，适合复杂推理
                    'claude-sonnet-4-6', -- 推荐日常使用
                    'claude-haiku-4-5-20251001', -- 最快，适合简单任务
                  },
                },
                max_tokens = {
                  default = 8192,
                },
              },
            })
          end,

        }, -- end adapters.http

        -- ════════════════════════════════════════════════════════════
        --  ACP ADAPTERS（Agent Client Protocol，需要本地 CLI 工具）
        --  ACP adapter 只支持 chat interaction，不支持 inline/cmd
        -- ════════════════════════════════════════════════════════════
        acp = {

          -- ── Claude Code（ACP）────────────────────────────────────
          -- 前置条件：
          --   1. npm install -g @anthropic-ai/claude-code
          --   2. npm install -g @zed-industries/claude-agent-acp  ← ACP bridge
          --   3a. 用 API key：export ANTHROPIC_API_KEY=sk-ant-xxx
          --   3b. 用 Claude Pro 订阅：claude setup-token
          --
          -- 与 HTTP anthropic 的区别：
          --   - claude_code 走本地 CLI，有 agentic 能力（文件读写、shell 等）
          --   - anthropic   走 REST API，是普通 chat，无 agentic 工具调用
          claude_code = function()
            return require('codecompanion.adapters').extend('claude_code', {
              env = {
                -- 二选一：API key 或 OAuth token（Claude Pro 订阅）
                ANTHROPIC_API_KEY = 'ANTHROPIC_API_KEY',
                -- CLAUDE_CODE_OAUTH_TOKEN = 'CLAUDE_CODE_OAUTH_TOKEN',
              },
              defaults = {
                -- 用函数形式可绕过 Claude Code SDK 的已知限制（见文档）
                ---@param self CodeCompanion.ACPAdapter
                ---@return string
                model = function(self) return 'sonnet' end,
                -- 可选值: 'sonnet' | 'opus' | 'haiku'
              },
            })
          end,

          -- ── Codex（ACP）──────────────────────────────────────────
          -- 前置条件：
          --   1. npm install -g @openai/codex
          --   2. npm install -g @zed-industries/codex-acp  ← ACP bridge
          --   3. export OPENAI_API_KEY=sk-xxx
          --      或者用 ChatGPT 订阅（auth_method = 'chatgpt'）
          codex = function()
            return require('codecompanion.adapters').extend('codex', {
              defaults = {
                auth_method = 'openai-api-key', -- 'openai-api-key'|'codex-api-key'|'chatgpt'
              },
              env = {
                OPENAI_API_KEY = 'OPENAI_API_KEY',
              },
            })
          end,

        }, -- end adapters.acp

      }, -- end adapters

      display = {
        action_palette = {
          provider = 'snacks', -- 联动你的 Snacks 选择器
        },
        chat = {
          window = { width = 0.4 },
          -- 关闭内置分割线，让 render-markdown 接管渲染
          show_header_separator = false,
        },
      },

    }) -- end setup
  end
})
