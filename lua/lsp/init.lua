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

local icons = require('icons')

-- 补全提示框图标
local function setupLspIcons()
  -- 配置 lsp 的图标
  require('vim.lsp.protocol').CompletionItemKind = {
    Text = icons.lsp.Text,
    Method = icons.lsp.Method,
    Function = icons.lsp.Function,
    Constructor = icons.lsp.Constructor,
    Field = icons.lsp.Field,
    Variable = icons.lsp.Variable,
    Class = icons.lsp.Class,
    Interface = icons.lsp.Interface,
    Module = icons.lsp.Module,
    Property = icons.lsp.Property,
    Unit = icons.lsp.Unit,
    Value = icons.lsp.Value,
    Enum = icons.lsp.Enum,
    Keyword = icons.lsp.Keyword,
    Snippet = icons.lsp.Snippet,
    Color = icons.lsp.Color,
    File = icons.files.File,
    Reference = icons.lsp.Reference,
    Folder = icons.folders.Open,
    EnumMember = icons.lsp.EnumMember,
    Constant = icons.lsp.Constant,
    Struct = icons.lsp.Struct,
    Event = icons.lsp.Event,
    Operator = icons.lsp.Operator,
    TypeParameter = icons.lsp.TypeParameter
  }
end

-- 侧栏缩略图标
local function setupLspSymbol()
  local signs = {
    Hint = icons.lsp.CodeAction,
    Error = icons.lsp.Error,
    Warn = icons.lsp.Warning,
    Info = icons.lsp.Info
  }

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
