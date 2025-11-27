-- Colorscheme
vim.pack.add({ "https://github.com/projekt0n/github-nvim-theme" })
vim.cmd.colorscheme("github_dark")

-- Cursor
vim.pack.add({ "https://github.com/sphamba/smear-cursor.nvim" })
require("smear_cursor").setup({
	smear_between_buffers = true,
})
