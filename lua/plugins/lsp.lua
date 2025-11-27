-- Language server protocol
vim.pack.add({
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
})
require("mason").setup()
vim.lsp.enable("lua_ls")

-- Diagnostic
vim.pack.add({ "https://github.com/rachartier/tiny-inline-diagnostic.nvim" })
require("tiny-inline-diagnostic").setup()
vim.diagnostic.config({ virtual_text = false })

-- Completion
vim.pack.add({ "https://github.com/Saghen/blink.cmp" })
require("blink.cmp").setup({
	keymap = { preset = "enter" },
	appearance = { nerd_font_variant = 'mono' },
	-- completion = { documentation = { auto_show = false } },
	sources = {
		default = { 'lsp', 'path', 'snippets', 'buffer' },
	},
	-- build = 'cargo build --release'
	-- fuzzy = { implementation = "prefer_rust_with_warning" },
	fuzzy = { implementation = "lua" },
})

-- Formatter
vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
require("conform").setup({
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})
vim.keymap.set(
	{ "n" },
	"<leader>cf",
	function()
		require("conform").format({
			async = true,
			lsp_fallback = true,
			timeout_ms = 500,
		})
	end,
	{ desc = "Format file" }
)
