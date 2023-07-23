require('lazy').setup {
  -- ----- 美化 ----- --
  -- Github 样式主题
  {
    'projekt0n/github-nvim-theme',
    lazy = false,    -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
  },
  -- 透明主题
  { 'xiyaowong/transparent.nvim' },
  -- 平滑滚动
  {
    'karb94/neoscroll.nvim',
    lazy = true
  },

  -- ----- 模块 ----- --
  -- 底部状态栏
  {
    'nvim-lualine/lualine.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons'
  },
  -- 侧边栏（文件树）
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = 'nvim-tree/nvim-web-devicons',
    lazy = true
  },
  -- 顶栏（窗口管理）
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    lazy = true
  },

  -- ----- 主窗口 ----- --
  -- 语法高亮
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = true
  },
  -- 彩虹括号
  {
    'HiPhish/nvim-ts-rainbow2',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    lazy = true
  },
  -- Mason
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate", -- :MasonUpdate updates registry contents
    lazy = true
  },
  -- LSP
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
    },
  },
  -- LSP 格式化
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
    lazy = true
  },
  -- 填充提示（更详细）
  { "ray-x/lsp_signature.nvim" },
  -- 自动补全
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-path" }, -- 文件路径
  { "L3MON4D3/LuaSnip", lazy = true }, -- snippets引擎，不装这个自动补全会出问题
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },
  -- 快速注释
  { 'numToStr/Comment.nvim', lazy = true },
  -- 自动补全括号
  { "windwp/nvim-autopairs", lazy = true },
  -- 颜色识别
  { "norcalli/nvim-colorizer.lua", lazy = true },

  -- ----- 辅助工具 ----- --
  -- 快捷窗口切换
  { 'christoomey/vim-tmux-navigator' },
  -- Git 状态展示
  { 'lewis6991/gitsigns.nvim', lazy = true },
  -- 文件/内容检索 Telescope
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = 'nvim-lua/plenary.nvim',
    lazy = true
  },
  -- Copilot
  { 'github/copilot.vim', lazy = true },
  -- 键盘映射提示 Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end
  },
  -- 主页仪表盘 Dashboard
  {
    'glepnir/dashboard-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  -- Git 增强
  {
    "tpope/vim-fugitive",
    event = "VeryLazy"
  }
}
