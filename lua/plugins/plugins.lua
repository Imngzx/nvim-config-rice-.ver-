require('lazy').setup {
  -- ----- 主题 ----- --
  -- Github 样式主题
  { 'projekt0n/github-nvim-theme' },
  -- 透明主题
  { 'xiyaowong/transparent.nvim' },

  -- ----- 模块 ----- --
  -- 底部状态栏
  {
    'nvim-lualine/lualine.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons'
  },
  -- 侧边栏（文件树）
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = 'nvim-tree/nvim-web-devicons'
  },
  -- 顶栏（窗口管理）
  {
    'akinsho/bufferline.nvim', version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons'
  },

  -- ----- 主窗口 ----- --
  -- 语法高亮
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })
    end,
  },
  -- 彩虹括号
  {
    'HiPhish/nvim-ts-rainbow2',
    dependencies = { 'nvim-treesitter/nvim-treesitter' }
  },
  -- LSP
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      {
        "williamboman/mason.nvim",
        build = ":MasonUpdate" -- :MasonUpdate updates registry contents 
      },
    }
  },
  -- 主窗口：LSP 增强
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      --Please make sure you install markdown and markdown_inline parser
      { "nvim-treesitter/nvim-treesitter" }
    }
  },
  -- 自动补全
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-path" }, -- 文件路径
  { "L3MON4D3/LuaSnip" }, -- snippets引擎，不装这个自动补全会出问题
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },
  -- 快速注释
  { 'numToStr/Comment.nvim' },
  -- 自动补全括号
  { "windwp/nvim-autopairs" },

  -- ----- 辅助工具 ----- --
  -- 快捷窗口切换
  { 'christoomey/vim-tmux-navigator' },
  -- Git 管理
  {
    'lewis6991/gitsigns.nvim',
  },
  -- 文件、内容检索
  {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    dependencies = 'nvim-lua/plenary.nvim'
  }

}
