require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = {
    -- 静态文件
    "lua_ls", -- NeoVim 自身 
    "marksman", -- Markdown
    "lemminx", -- XML
    "yamlls", -- YAML
    "taplo", -- TOML
    "jsonls", -- JSON

    -- 脚本文件
    "bashls", -- Bash
    "powershell_es", -- powershell

    -- 编程语言
    "clangd", "cmake", -- C/Cpp/Qt
    "matlab_ls", -- Matlab
    "jdtls", -- Java
    "pyright", -- Python
    "r_language_server", -- R
    "sqlls", -- SQL

    -- 前端
    "html", "tsserver", "cssls", -- HTML/JS/TS/CSS
    "volar", -- Vue
    -- "tailwindcss", -- Tailwind CSS
  }
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
