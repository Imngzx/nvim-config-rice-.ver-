require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = { "lua_ls" }
}

-- After setting up mason-lspconfig you may set up servers via lspconfig
-- require("lspconfig").lua_ls.setup {}
-- require("lspconfig").rust_analyzer.setup {}
-- ...

-- 与 cmp 结合
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("lspconfig").lua_ls.setup {
  capabilities = capabilities,
}
