-- 自动安装
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer()

local packer_result = require('packer').startup(function(use)
  -- ----- Packer 自己 ----- --
  use 'wbthomason/packer.nvim'

  -- ----- 主题 ----- --
  -- Github 样式主题
  use 'projekt0n/github-nvim-theme'
  -- 透明主题
  use 'xiyaowong/transparent.nvim'

  -- ----- 模块 ----- --
  -- 底部状态栏
  use {
    'nvim-lualine/lualine.nvim',
    requires = 'nvim-tree/nvim-web-devicons'
  }
  -- 侧边栏（文件树）
  use {
    'nvim-tree/nvim-tree.lua',
    requires = 'nvim-tree/nvim-web-devicons'
  }
  -- 顶栏（窗口管理）
  use {
    'akinsho/bufferline.nvim',
    tag = "*",
    requires = 'nvim-tree/nvim-web-devicons'
  }

  -- ----- 主窗口 ----- --
  -- 语法高亮
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({
        with_sync = true
      })
      ts_update()
    end
  }
  -- 彩虹括号
  use {
    'HiPhish/nvim-ts-rainbow2',
    requires = { 'nvim-treesitter/nvim-treesitter' }
  }
  -- LSP
  use {
    "williamboman/mason.nvim",
    run = ":MasonUpdate" -- :MasonUpdate updates registry contents
  }
  use { "williamboman/mason-lspconfig.nvim", "neovim/nvim-lspconfig" }
  -- 主窗口：LSP 增强
  use {
    'glepnir/lspsaga.nvim',
    -- Please make sure you install markdown and markdown_inline parser
    requires = {'nvim-tree/nvim-web-devicons', 'nvim-treesitter/nvim-treesitter'}
  }
  -- 自动补全
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-path" -- 文件路径
  use "L3MON4D3/LuaSnip" -- snippets引擎，不装这个自动补全会出问题
  use "saadparwaiz1/cmp_luasnip"
  use "rafamadriz/friendly-snippets"
  -- 快速注释
  use 'numToStr/Comment.nvim'
  use "windwp/nvim-autopairs"

  -- 辅助工具：快捷窗口切换
  use 'christoomey/vim-tmux-navigator'
  -- 辅助工具：Git 管理
  use {
    'lewis6991/gitsigns.nvim',
    -- tag = 'release' -- To use the latest release (do not use this if you run Neovim nightly or dev builds!)
  }
  use {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    requires = 'nvim-lua/plenary.nvim'
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- 保存此文件自动更新安装插件
-- 注意 PackerCompile 改成了 PackerSync
-- plugins.lua 改成了 plugins-setup.lua，适应本地名字
vim.cmd([[
  augroup packer_user_cofig
  autocmd!
  autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
  augroup end
]])

return packer_result
