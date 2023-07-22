local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local completion = null_ls.builtins.completion

null_ls.setup({
  sources = {
    formatting.prettier,
    formatting.clang_format,
    -- completion.spell,
    -- completion.luasnip,
  },
})

require("mason-null-ls").setup({
  ensure_installed = {
    "prettier",
    "clang-format",
  },
  automatic_installation = true,
})

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, {})
