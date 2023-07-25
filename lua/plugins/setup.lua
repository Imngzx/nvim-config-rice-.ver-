local list = {
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
    dependencies = 'nvim-tree/nvim-web-devicons',
    event = "VeryLazy",
  },
  -- 侧边栏（文件树）
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    }
  },
  -- 顶栏（窗口管理）
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    lazy = true
  },

  -- ----- 主窗口 ----- --
  -- 快速注释
  { 'numToStr/Comment.nvim',       lazy = true },
  -- 自动补全括号
  { "windwp/nvim-autopairs", },
  -- 颜色识别
  { "norcalli/nvim-colorizer.lua", lazy = true },
  -- 缩进线
  {
    "lukas-reineke/indent-blankline.nvim",
    lazy = true,
    event = { "BufReadPost", "BufNewFile" },
  },

  -- ----- 辅助工具 ----- --
  -- 快捷窗口切换
  { 'christoomey/vim-tmux-navigator' },
  -- Git 状态展示
  {
    'lewis6991/gitsigns.nvim',
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
  },
  -- 文件/内容检索 Telescope
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = 'nvim-lua/plenary.nvim',
    lazy = true
  },
  -- Copilot
  {
    'github/copilot.vim',
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
  },
  -- 键盘映射提示 Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
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

-- LSP
local lsp = require('lsp.setup')
table.insert(list, lsp)

require('lazy').setup(list)
