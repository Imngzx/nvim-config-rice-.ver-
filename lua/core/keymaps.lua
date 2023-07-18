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

-- 文件操作
-- 保存
keymap.set("n", "<leader>w", ":w<CR>")
-- 退出
keymap.set("n", "<leader>q", ":q<CR>")

-- 代码操作
-- 删除行
keymap.set("n", "xx", ":delete<CR>")
-- 切换是否自动换行
keymap.set('n', '<leader>x', ':set invwrap<CR>', { noremap = true })
-- 取消搜索高亮
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- ----- 插件 ----- --
-- NvimTreeToggle
keymap.set("n", "<leader>b", ":NvimTreeToggle<CR>")
-- Bufferline
keymap.set("n", "L", ":bnext<CR>")
keymap.set("n", "H", ":bprevious<CR>")

