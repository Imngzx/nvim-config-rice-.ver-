-- [LSP]
vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
})
require("mason").setup({
  ensure_installed = {
    -- LSP
    "vtsls",
    -- Formatter
    "stylua",
    "prettier",
    "shfmt",
  },
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})
vim.lsp.enable({ "lua_ls", "markdown" })
-- LSP attach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspKepmap", {}),
  callback = function(ev)
    -- Use buffer-local keymaps
    local opts = function(desc)
      return { buffer = ev.buf, desc = desc }
    end
    -- LSP keymaps
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("LSP hover"))
    vim.keymap.set("n", "<leader>ch", vim.lsp.buf.hover, opts("LSP hover"))
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Goto definition"))
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Goto declaration"))
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("List references"))
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Goto implementation"))
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts("Type definition"))
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts("Rename symbol"))
    vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, opts("Code action"))
    vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts("Signature help"))
  end,
})

-- [Formatter]
vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
  },
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})
vim.keymap.set("n", "<leader>cf",
  function()
    require("conform").format({
      async = true,
      lsp_fallback = true,
      timeout_ms = 500,
    })
  end,
  { desc = "Format file" }
)

-- [Diagnostic]
vim.pack.add({ "https://github.com/rachartier/tiny-inline-diagnostic.nvim" })
require("tiny-inline-diagnostic").setup({
  preset = "powerline",
  signs = { diag = "-" },
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
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- [Completion]
vim.pack.add({ "https://github.com/Saghen/blink.cmp" })
require("blink.cmp").setup({
  keymap = { preset = "enter" },
  appearance = { nerd_font_variant = 'mono' },
  -- completion = { documentation = { auto_show = false } },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  -- build = 'cargo build --release'
  -- fuzzy = { implementation = "prefer_rust_with_warning" },
  fuzzy = { implementation = "lua" },
})
