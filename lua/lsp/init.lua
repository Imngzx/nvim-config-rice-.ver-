-- 语法高亮：nvim-treesitter
require("lsp.treesitter")
-- LSP 包管理：Mason
require("lsp.mason")
-- LSP 基础：lsp
require("lsp.mason-lspconfig")
-- LSP 增强：null-ls
require("lsp.null-ls")
-- LSP 综合体验提升
require("lsp.lspsaga")
-- 自动补全：cmp
require("lsp.cmp")

-- 补全提示框图标
local function setupLspIcons()
  -- 配置 lsp 的图标
  require('vim.lsp.protocol').CompletionItemKind = {
    Text = '𝓐', --   𝓐
    Method = 'ƒ', --  ƒ
    Function = '', -- 
    Constructor = '', --   
    Field = '', --  ﴲ ﰠ   
    Variable = '', --   
    Class = '𝓒', --  ﴯ 𝓒
    Interface = '', -- ﰮ    
    Module = '', --   
    Property = '', -- ﰠ 襁
    Unit = '', --  塞
    Value = '',
    Enum = 'ℰ', -- 練 ℰ 
    Keyword = '🔐', --   🔐
    Snippet = '', -- ﬌  ⮡ 
    Color = '',
    File = '', --  
    Reference = '', --  
    Folder = '', --  
    EnumMember = '',
    Constant = '', --  
    Struct = '𝓢', --   𝓢 פּ
    Event = '', --  🗲
    Operator = '+', --   +
    TypeParameter = '𝙏', --  𝙏
  }
end

-- 侧栏缩略图标
local function setupLspSymbol()
  local signs = { Error = '', Warn = '', Hint = '', Info = '' }

  local function lspSymbol(name, icon)
    local hl = 'DiagnosticSign' .. name
    vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
  end

  for type, icon in pairs(signs) do
    lspSymbol(type, icon)
  end
end

-- 执行
setupLspIcons()
setupLspSymbol()
