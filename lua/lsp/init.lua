local M = {}

-- 【1】this section just handles lsp installation
local default_servers = {

  -- [markdown]
  marksman = true,

  -- [json]
  jsonls = 'json-lsp',

  -- [toml]
  taplo = true,

  -- [for .fish files]
  fish_lsp = 'fish-lsp',

  -- [bash, sh]
  bashls = 'bash-language-server', -- HACK: install shellcheck for inline diagnostic

  --[HTML]
  html = 'html-lsp',
  emmet_language_server = 'emmet-language-server',
}

-- 【2】this section can handle installation + configurations
-- tools that noted with mason=false wont be installed via Mason automatically
local custom_servers = {

  -- [c/c++ and etc]
  clangd = require('lsp.servers.c-language'), --NOTE: mason = false

  -- [zig]
  zls = require('lsp.servers.zig'), --NOTE: mason = false

  -- [rust]
  rust_analyzer = require('lsp.servers.rust'), --NOTE: mason = false

  -- [qml]
  qmlls6 = require('lsp.servers.qml'), --NOTE: mason = false

  -- [lua]
  lua_ls = require('lsp.servers.lua').lua_ls,
  -- emmylua_ls = require('lsp.servers.lua').emmylua_ls,

  -- [python]
  basedpyright = require('lsp.servers.python').basedpyright,
  ruff = require('lsp.servers.python').ruff,
  -- ty = require('lsp.servers.python').ty, --NOTE: mason = false


  -- vtsls = require('lsp.servers.vue'),
}

-- 【3】this handles tool installation from mason other than lsp
M.mason_tools = {
  'codelldb', -- C/C++/Rust 调试器
  'debugpy', -- Python 调试器
  'shfmt', -- Shell 格式化器
  'prettier',
  'prettierd',
  'cmakelang',
  'markdownlint-cli2',
  'htmlhint',
  'shellcheck',
  -- 'vue-language-server',
}

M.enabled_servers = {}

function M.setup()
  for name, mason_pkg in pairs(default_servers) do
    table.insert(M.enabled_servers, name)
    table.insert(M.mason_tools, type(mason_pkg) == 'string' and mason_pkg or name)
    vim.lsp.config(name, {})
  end

  for name, config in pairs(custom_servers) do
    table.insert(M.enabled_servers, name)

    if config.mason ~= false then
      table.insert(M.mason_tools, config.mason_name or name)
    end

    local safe_config = vim.deepcopy(config)
    safe_config.mason = nil
    safe_config.mason_name = nil

    vim.lsp.config(name, safe_config)
  end
end

return M
