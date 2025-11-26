local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = " "

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>b", "<cmd>BufferLineCyclePrev<cr><cmd>bd #<cr>", { desc = "Close buffer" }) -- close
map("n", "<leader>cp", ":set spell!<CR>", { desc = "Toggle spelling" })
