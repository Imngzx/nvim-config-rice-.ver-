local M = {}

-- 【1】纯净版 LSP：只需名字，无需配置，Mason 自动装，Nvim 自动启
local default_servers = {
  marksman = true,
  jsonls = 'json-lsp',
  taplo = true,
  fish_lsp = 'fish-lsp',
  bashls = 'bash-language-server', -- HACK: install shellcheck for inline diagnos
}

-- 【2】定制版 LSP：引入你在 lua/lsp/servers/ 下写的配置
local custom_servers = {
  clangd = require('lsp.servers.c-language'), --NOTE: mason = false
  zls = require('lsp.servers.zig'), --NOTE: mason = false
  qmlls6 = require('lsp.servers.qml'), --NOTE: mason = false
  -- vtsls = require('lsp.servers.vue'),
  lua_ls = require('lsp.servers.lua').lua_ls,
  -- emmylua_ls = require('lsp.servers.lua').emmylua_ls,
  basedpyright = require('lsp.servers.python').basedpyright,
  ruff = require('lsp.servers.python').ruff,
  -- ty = require('lsp.servers.python').ty, --NOTE: mason = false
}

-- 【3】其他开发工具：仅用 Mason 安装，不作为 LSP 启动
M.mason_tools = {
  'codelldb', -- C/C++/Rust 调试器
  'debugpy', -- Python 调试器
  'shfmt', -- Shell 格式化器
  'prettier',
  'prettierd',
  'cmakelang',
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
