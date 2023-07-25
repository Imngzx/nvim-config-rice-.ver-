-- 自动安装
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 安装列表
require("plugins.setup")

-- 美化
-- 主题：github-nvim-theme
require("plugins.github-theme")
-- 透明化：transparent.nvim
require("plugins.transparent")
-- 平滑滚动：neoscroll.nvim
require("plugins.neoscroll")

-- 模块
-- 底栏：lualine.nvim
require("plugins.lualine")
-- 侧栏：neo-tree.lua
require("plugins.neo-tree")
-- 顶栏：bufferline
require("plugins.bufferline")

-- 主窗口
-- 快速注释：comment
require("plugins.comment")
-- 自动补全括号：autopairs
require("plugins.autopairs")
-- 颜色识别：nvim-colorizer.lua
require("plugins.colorizer")

-- 辅助工具
-- Git 标记：gitsigns
require("plugins.gitsigns")
-- 文件/内容检索：telescope
require("plugins.telescope")
-- 主页仪表盘：dashboard-nvim
require("plugins.dashboard")
