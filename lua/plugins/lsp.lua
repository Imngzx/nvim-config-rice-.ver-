local lazy = require('libs.lazy')
local H = {}

-- calls the second init in this config
local lsp_manager = require('lsp.init')
lsp_manager.setup()

H.conform = {
  python = function(bufnr)
    if require('conform').get_formatter_info('ruff_format', bufnr).available then
      return { 'ruff_format' }
    else
      return { 'isort', 'black' }
    end
  end,
  javascript = { 'prettierd', 'prettier', stop_after_first = true },
  html = { 'prettierd', 'prettier', stop_after_first = true },
  css = { 'prettierd', 'prettier', stop_after_first = true },
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

-- [Dependencies] Mason auto install once you open the Mason panel
lazy.load({
  plugin = 'https://github.com/mason-org/mason.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonLog', 'MasonUpdate' },
  keys = {
    { 'n', '<leader>pm', function()
      vim.cmd('Mason')
      local registry = require('mason-registry')
      registry.refresh(function()
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

lazy.load({
  plugin = 'https://github.com/neovim/nvim-lspconfig',
  event = { 'User', pattern = 'VeryLazy' },
  setup = function()
    -- using the lsp or tools that listed inside the init that located inside "lsp" directory
    vim.lsp.enable(lsp_manager.enabled_servers)
  end
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LspKepmap', {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
    -- LSP keymaps
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buf = ev.buf, desc = 'LSP hover' })
    vim.keymap.set('n', '<leader>ch', vim.lsp.buf.hover, { buf = ev.buf, desc = 'LSP hover' })
    -- Moved to Snacks
    -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc='Goto definition'})
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc='Goto declaration'})
    -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, {
    --   buffer = ev.buf,
    --   desc =
    --   'List references'
    -- })

    -- commented conflicted keymaps with keys.lua around line 60 and 61
    -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation,
    --   { buffer = ev.buf, desc = 'Goto implementation' })
    -- vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition,
    --   { buffer = ev.buf, desc = 'Type definition' })

    vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, { buf = ev.buf, desc = 'Rename symbol' })
    vim.keymap.set({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action,
      { buf = ev.buf, desc = 'Code action' })
    vim.keymap.set('i', '<c-k>', vim.lsp.buf.signature_help,
      { buf = ev.buf, desc = 'Signature help' })
    vim.keymap.set('n', '<leader>pl', '<cmd>checkhealth vim.lsp<cr>', { desc = '[Panel] Lsp info' })
    -- vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format,
    --   { buffer = ev.buf, desc = 'Format code' })
  end,
})

-- [Formatter] Multi-trigger: load on save or keymap
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
        timeout_ms = 800,
        lsp_format = 'fallback',
      },
    })
  end
})

lazy.load({
  plugin = 'https://github.com/folke/lazydev.nvim',
  ft = 'lua',
  setup = function()
    require('lazydev').setup({
      library = {
        vim.fn.stdpath('data') .. '/site/pack/core/opt/*',
        vim.fn.stdpath('config') .. '/lua',
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    })
  end
})

lazy.load({
  plugin = 'https://github.com/Bilal2453/luvit-meta',
  ft = 'lua'
})

-- [Diagnostic] Load after LSP attaches
-- https://github.com/rachartier/tiny-inline-diagnostic.nvim/issues/112#issuecomment-2784644922
lazy.load({
  plugin = 'https://github.com/rachartier/tiny-inline-diagnostic.nvim',
  event = { 'User', pattern = 'VeryLazy' },
  setup = function()
    require('tiny-inline-diagnostic').setup({
      preset = 'modern',
      signs = { diag = '  ' },
      transparent_cursorline = true,
      options = {
        virt_texts = {
          priority = 2048,
        },
        show_source = {
          enabled = true,
        },
      },
    })
    vim.diagnostic.config({
      virtual_text = false, --leave this with false when you using this plugin
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = 'rounded',
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = ' ',
          [vim.diagnostic.severity.WARN] = ' ',
          [vim.diagnostic.severity.HINT] = ' ',
          [vim.diagnostic.severity.INFO] = ' ',
        },
      },
    })

    -- Keymap
    local diagnostic_goto = function(next, severity)
      return function()
        vim.diagnostic.jump({
          count = (next and 1 or -1) * vim.v.count1,
          severity = severity and vim.diagnostic.severity[severity] or nil,
          on_jump = function()
            vim.diagnostic.open_float()
          end,
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
        enabled = true,
        keymap = {
          preset = 'enter',
          ['<C-y>'] = { 'select_and_accept' },
        },
        completion = {
          list = { selection = { preselect = false } },
          menu = {
            auto_show = true,
          },
          ghost_text = {
            enabled = true,
          },
        },
      },

      sources = {
        -- 在注释行时不显示菜单补全。并且在全局不会弹出中文补全
        default = function()
          local cursor = vim.api.nvim_win_get_cursor(0)
          local row, col = cursor[1], cursor[2]

          local ok, node = pcall(vim.treesitter.get_node, {
            bufnr = 0,
            pos = { row - 1, math.max(0, col - 1) },
          })
          if ok and node and node.type and node:type():find('comment') then
            return {}
          end
          if vim.bo.filetype == 'lua' then
            return { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' }
          end
          return { 'lsp', 'path', 'snippets', 'buffer' }
        end,
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
          snippets = {
            opts = {
              friendly_snippets = true,
              -- markdown = { 'jekyll' },
              -- sh = { 'shelldoc' },
              -- php = { 'phpdoc' },
              -- cpp = { 'unreal' }
            }
          }
        },
      },

      fuzzy = { implementation = 'prefer_rust_with_warning' },
    })
  end
})
