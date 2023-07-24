-- 设置 leader 键
vim.g.mapleader = " "

-- 单行或多行移动
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<M-k>", ":m '>-2<CR>gv=gv")

-- 退出终端
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', {noremap=true})

-- 键盘映射提示：which-key.nvim
require("keymaps.which-key")

