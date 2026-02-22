local lazy = require('libs.lazy')
-- [Config]
local H = {}

-- (Env) mason
-- `:Mason` to see the list
H.mason = {
  -- LSP
  'lua_ls', -- lua
  'vtsls', -- typescript
  'css-lsp', -- css
  'marksman', -- markdown
  'ty', -- python
  -- Formatter
  'prettier', -- front-end
  'shfmt', -- shell
  'ruff' -- python
}

-- (Lsp) lspconfig
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
H.lsp = { 'lua_ls', 'vtsls', 'cssls', 'vue_ls', 'marksman', 'ty' }

-- (Formatter) conform
-- https://github.com/stevearc/conform.nvim#formatters
-- Or use `:help conform-formatters`
H.conform = {
  markdown = { 'prettier' },
  vue = { 'prettier' },
  python = { 'ruff' },
  css = { 'prettier' },
}

-- (Specific)
local vue_language_server_path = vim.fn.stdpath('data') ..
  '/mason/packages/vue-language-server/node_modules/@vue/language-server'
local vue_plugin = {
  name = '@vue/typescript-plugin',
  location = vue_language_server_path,
  languages = { 'vue' },
  configNamespace = 'typescript',
}
vim.lsp.config('vtsls', {
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          vue_plugin,
        },
      },
    },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
})

vim.g.markdown_fenced_languages = {
  'sh', 'bash=sh',
  'python', 'py=python',
  'javascript', 'js=javascript',
  'typescript', 'ts=typescript',
  'html',
  'css',
  'json',
  'lua',
  'vim',
}

-- [Dependencies] Load on run `Mason` command, key, and event
lazy.load({
  plugin = 'https://github.com/mason-org/mason.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonLog', 'MasonUpdate' },
  keys = {
    { 'n', '<leader>pm', function() vim.cmd('Mason') end, { desc = '[Panel] Mason' } }
  },
  setup = function()
    require('mason').setup({
      ensure_installed = H.mason,
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      },
    })
  end
})

-- [LSP] Load when opening files or delay

lazy.on_event({ 'User', pattern = 'VeryLazy' },
  'https://github.com/neovim/nvim-lspconfig',
  function()
    vim.lsp.enable(H.lsp)
    -- LSP attach
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('LspKepmap', {}),
      callback = function(ev)
        -- LSP keymaps
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = 'LSP hover' })
        vim.keymap.set('n', '<leader>ch', vim.lsp.buf.hover, { buffer = ev.buf, desc = 'LSP hover' })
        -- Moved to Snacks
        -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc='Goto definition'})
        -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc='Goto declaration'})
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, {
          buffer = ev.buf,
          desc =
          'List references'
        })
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
        -- vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format,
        --   { buffer = ev.buf, desc = 'Format code' })
      end,
    })
    vim.keymap.set('n', '<leader>pl', '<cmd>checkhealth vim.lsp<cr>', { desc = '[Panel] Lsp info' })
  end
)

-- [Formatter] Multi-trigger: load on save or keymap
vim.pack.add({ 'https://github.com/stevearc/conform.nvim' })
lazy.load({
  plugin = 'https://github.com/stevearc/conform.nvim',
  event = 'BufWritePre',
  keys = {
    { 'n', '<leader>cf', function()
      require('conform').format({ async = true, lsp_format = 'fallback' })
    end, { desc = 'Format file' } }
  },
  setup = function()
    require('conform').setup({
      formatters_by_ft = H.conform,
      format_after_save = {
        async = true,
        lsp_format = 'fallback',
      },
    })
  end
})

-- [Diagnostic] Load after LSP attaches
lazy.on_event('LspAttach', 'https://github.com/rachartier/tiny-inline-diagnostic.nvim', function()
  require('tiny-inline-diagnostic').setup({
    preset = 'powerline',
    signs = { diag = '-' },
  })
  vim.diagnostic.config({ virtual_text = false })

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
end)

-- [Completion] Load on InsertEnter
lazy.on_event('InsertEnter',
  { { src = 'https://github.com/Saghen/blink.cmp', version = vim.version.range('1') } },
  function()
    require('blink.cmp').setup({
      keymap = { preset = 'enter' },
      appearance = { nerd_font_variant = 'mono' },
      completion = { documentation = { auto_show = true } },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' }, },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    })
  end
)
