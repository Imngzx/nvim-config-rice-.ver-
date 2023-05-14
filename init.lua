-- ----- 主设置 ----- --
require("core.options")
require("core.keymaps")

-- ----- 插件 ----- --
require("plugins.plugins-setup")

-- 主题：github-nvim-theme
require("plugins.github-theme")
-- 主题：transparent.nvim
require("plugins.transparent")

-- 底栏：lualine.nvim
require("plugins.lualine")
-- 侧栏：nvim-tree.lua
require("plugins.nvim-tree")
-- 顶栏：bufferline
require("plugins.bufferline")

-- 主界面：nvim-treesitter
require("plugins.treesitter")
-- 主界面：lsp
require("plugins.lsp")
-- 主界面：lspsaga
require("plugins.lspsaga")
-- 主界面：cmp
require("plugins.cmp")
-- 主界面：comment
require("plugins.comment")
-- 主界面：autopairs
require("plugins.autopairs")

-- 辅助工具：gitsigns
require("plugins.gitsigns")
-- 辅助工具：telescope
require("plugins.telescope")
