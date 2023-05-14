-- 设置 leader 键
vim.g.mapleader = " "

local keymap = vim.keymap

-- ----- 插入模式 ----- --


-- ----- 视觉模式 ----- --
-- 单行或多行移动
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '>-2<CR>gv=gv")

-- ----- 正常模式 ----- --
-- 窗口
keymap.set("n", "<leader>sv", "<C-w>v") -- 右侧新增窗口
keymap.set("n", "<leader>sh", "<C-w>s") -- 底部新增窗口
-- 开辟终端窗口
keymap.set("n", "<leader>`", "<C-w>s :term<CR>")

-- 取消高亮
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- ----- 插件 ----- --
-- NvimTreeToggle
keymap.set("n", "<leader>b", ":NvimTreeToggle<CR>")
-- Bufferline
keymap.set("n", "L", ":bnext<CR>")
keymap.set("n", "H", ":bprevious<CR>")

