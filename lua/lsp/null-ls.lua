local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local completion = null_ls.builtins.completion

null_ls.setup({
  sources = {
    -- 综合
    formatting.prettier,
    -- completion.spell,

    -- C/C++
    formatting.clang_format,
    -- Lua
    completion.luasnip,
    -- Python
    formatting.black
  },
})

require("mason-null-ls").setup({
  ensure_installed = {
    "black",
    "clang-format",
    "prettier",
  },
  automatic_installation = true,
})

