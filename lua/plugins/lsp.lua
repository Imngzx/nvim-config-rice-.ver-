local lazy = require('libs.lazy')
local H = {}

-- 🌟 1. 唤醒 LSP 调度中心
local lsp_manager = require('lsp.init')
lsp_manager.setup()

-- (Formatter) conform 保持原样
H.conform = {
  python = function(bufnr)
    if require('conform').get_formatter_info('ruff_format', bufnr).available then
      return { 'ruff_format' }
    else
      return { 'isort', 'black' }
    end
  end,
  javascript = { 'prettierd', 'prettier', stop_after_first = true },
  rust = { 'rustfmt' },
  c = { 'clang_format' },
  cpp = { 'clang_format' },
  sh = { 'shfmt' },
  bash = { 'shfmt' },
  toml = { 'taplo' },
  cmake = { 'cmake_format' },
  json = { 'jq' },
  zig = { 'zigfmt' },
}

vim.g.markdown_fenced_languages = {
  'sh', 'bash=sh', 'python', 'py=python', 'javascript', 'js=javascript',
  'typescript', 'ts=typescript', 'html', 'css', 'json', 'lua', 'vim',
}

-- [Dependencies] Mason 自动化安装
lazy.load({
  plugin = 'https://github.com/mason-org/mason.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonLog', 'MasonUpdate' },
  keys = {
    { 'n', '<leader>pm', function()
      vim.cmd('Mason')
      local registry = require('mason-registry')
      registry.refresh(function()
        -- 🌟 2. 直接遍历大脑里计算好的工具名单！
        for _, pkg_name in ipairs(lsp_manager.mason_tools) do
          local ok, pkg = pcall(registry.get_package, pkg_name)
          if ok and not pkg:is_installed() then
            vim.schedule(function()
              pkg:install()
              vim.notify('[Mason] Auto installing ' .. pkg_name, vim.log.levels.INFO)
            end)
          end
        end
      end)
    end, { desc = '[Panel] Mason' } }
  },
  setup = function()
    require('mason').setup({
      ui = { icons = { package_installed = '✓', package_pending = '➜', package_uninstalled = '✗' } },
    })
  end
})

-- [LSP] 极速启动！
lazy.load({
  plugin = 'https://github.com/neovim/nvim-lspconfig',
  event = { 'User', pattern = 'VeryLazy' },
  setup = function()
    -- 🌟 3. 把开启名单喂给引擎
    vim.lsp.enable(lsp_manager.enabled_servers)
  end
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LspKepmap', {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/inlayHint') then
      -- 对当前 buffer 开启内联提示
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
    -- LSP keymaps
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = 'LSP hover' })
    vim.keymap.set('n', '<leader>ch', vim.lsp.buf.hover, { buffer = ev.buf, desc = 'LSP hover' })
    -- Moved to Snacks
    -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc='Goto definition'})
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc='Goto declaration'})
    -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, {
    --   buffer = ev.buf,
    --   desc =
    --   'List references'
    -- })
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation,
      { buffer = ev.buf, desc = 'Goto implementation' })
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition,
      { buffer = ev.buf, desc = 'Type definition' })
    vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename,
      { buffer = ev.buf, desc = 'Rename symbol' })
    vim.keymap.set({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action,
      { buffer = ev.buf, desc = 'Code action' })
    vim.keymap.set('i', '<c-k>', vim.lsp.buf.signature_help,
      { buffer = ev.buf, desc = 'Signature help' })
    vim.keymap.set('n', '<leader>pl', '<cmd>checkhealth vim.lsp<cr>', { desc = '[Panel] Lsp info' })
    -- vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format,
    --   { buffer = ev.buf, desc = 'Format code' })
  end,
})

-- [Formatter] Multi-trigger: load on save or keymap
-- vim.pack.add({ 'https://github.com/stevearc/conform.nvim' })
lazy.load({
  plugin = 'https://github.com/stevearc/conform.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  keys = {
    { 'n', '<leader>cf', function()
      require('conform').format({ async = true, lsp_format = 'fallback' })
    end, { desc = 'Format file' } }
  },
  setup = function()
    require('conform').setup({
      formatters_by_ft = H.conform,
      format_on_save = {
        timeout_ms = 800, -- 给 800 毫秒的宽限时间
        lsp_format = 'fallback',
      },
    })
  end
})

-- [Diagnostic] Load after LSP attaches
-- https://github.com/rachartier/tiny-inline-diagnostic.nvim/issues/112#issuecomment-2784644922
lazy.load({
  plugin = 'https://github.com/rachartier/tiny-inline-diagnostic.nvim',
  event = { 'User', pattern = 'VeryLazy' },
  setup = function()
    require('tiny-inline-diagnostic').setup({
      preset = 'powerline',
      signs = { diag = '  ' },
      options = {
        show_source = {
          enabled = true,
        },
      },
    })
    -- 自定义诊断 UI：包含行号栏图标、下划线、排序等
    vim.diagnostic.config({
      virtual_text = false, -- 因为你用了 tiny-inline-diagnostic，所以关闭原生虚拟文本
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = 'rounded',
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = ' ', -- 换成你喜欢的图标，比如 "✘"
          [vim.diagnostic.severity.WARN] = ' ', -- 比如 "▲"
          [vim.diagnostic.severity.HINT] = ' ', -- 比如 "⚑"
          [vim.diagnostic.severity.INFO] = ' ', -- 比如 "»"
        },
      },
    })

    -- Keymap
    local diagnostic_goto = function(next, severity)
      return function()
        vim.diagnostic.jump({
          count = (next and 1 or -1) * vim.v.count1,
          severity = severity and vim.diagnostic.severity[severity] or nil,
          float = true,
        })
      end
    end
    vim.keymap.set('n', '<leader>cl', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
    vim.keymap.set('n', ']d', diagnostic_goto(true), { desc = 'Next Diagnostic' })
    vim.keymap.set('n', '[d', diagnostic_goto(false), { desc = 'Prev Diagnostic' })
    vim.keymap.set('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next Error' })
    vim.keymap.set('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Prev Error' })
    vim.keymap.set('n', ']w', diagnostic_goto(true, 'WARN'), { desc = 'Next Warning' })
    vim.keymap.set('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Prev Warning' })
  end
})

-- [Completion] Load on InsertEnter and CmdlineEnter
lazy.load({
  plugin = {
    { src = 'https://github.com/Saghen/blink.cmp', version = vim.version.range('1') },
    'https://github.com/rafamadriz/friendly-snippets' -- 👇 新增：添加 friendly-snippets
  },
  -- 👇 1. 触发事件增加 CmdlineEnter
  -- event = { 'InsertEnter', 'CmdlineEnter' },
  event = { 'User', pattern = 'VeryLazy' },
  setup = function()
    require('blink.cmp').setup({
      keymap = { preset = 'enter' },
      appearance = { nerd_font_variant = 'mono' },

      signature = {
        window = {
          border = {
            'rounded',
          },
        },
      },
      completion = {
        ghost_text = {
          enabled = true,
        },
        documentation = {
          auto_show = true,
          window = {
            border = 'rounded',
            winhighlight =
            'Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None',
          }
        },
        menu = {

          --can comment this if you want cmp menu with darker color bg
          winhighlight =
          'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None',

          scrollbar = true,
          auto_show_delay_ms = 200,
          border = 'rounded',
          draw = {
            align_to = 'cursor',
            columns = { { 'kind_icon' }, { 'label', gap = 1 }, { 'menu', gap = 1 } },
            components = {
              label = {
                text = function(ctx)
                  return require('colorful-menu').blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require('colorful-menu').blink_components_highlight(ctx)
                end,
              },
              -- new menu component
              menu = {
                text = function(ctx)
                  local menu_labels = {
                    lsp = '[LSP]',
                    buffer = '[Buffer]',
                    snippets = '[LuaSnip]',
                    path = '[Path]',
                    lazydev = '[LazyDev]',
                  }
                  return menu_labels[ctx.source_name] or ('[' .. ctx.source_name .. ']')
                end,
                highlight = 'Comment', -- you can change to match your theme
              },
            },
          },
        },
      },

      cmdline = {
        -- enabled = true,
        --
        keymap = { preset = 'super-tab' }, -- 命令行使用vs code命令
        completion = {
          menu = {
            auto_show = true,
          },
        },
      },

      sources = {
        -- 在注释行时不显示菜单补全。并且在全局不会弹出中文补全
        default = function()
          -- 👇 将 unpack 改为直接获取并赋值，完美避开语法警告和兼容性问题
          local cursor = vim.api.nvim_win_get_cursor(0)
          local row, col = cursor[1], cursor[2]

          local ok, node = pcall(vim.treesitter.get_node, {
            bufnr = 0,
            pos = { row - 1, math.max(0, col - 1) },
          })
          if ok and node and node.type and node:type():find('comment') then
            return {}
          end
          return { 'lsp', 'path', 'snippets', 'buffer' }
        end,
      },

      fuzzy = { implementation = 'prefer_rust_with_warning' },
    })
  end
})
