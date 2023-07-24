-- 设置 leader 键
vim.g.mapleader = " "

-- 退出终端
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', {noremap=true})

-- 键盘映射提示：which-key.nvim
require("keymaps.which-key")

