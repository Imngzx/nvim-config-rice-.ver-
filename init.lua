require('custom.theme').setup() -- theme must be set before plugins

-- [Config]
require('config.options')
require('config.keymaps')
require('config.autocommands')

-- [Plugins]
-- vim.cmd.colorscheme('github-dark-custom')
require('plugins.ui')
require('plugins.lsp')
require('plugins.tool')
require('plugins.snacks')

-- [Custom]
-- UI
require('custom.transparent').setup({ auto_enable = true })
require('custom.tabline').setup({ hide_single_tab = true })
require('custom.statusline').setup({
  ft_icon = function(ft) return Snacks.util.icon(ft, 'filetype') end,
})
-- Edit
require('custom.pairs').setup()
require('custom.surround').setup()
