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
-- require('plugins.im-select')

-- [Custom]
-- UI
require('custom.transparent').setup({ auto_enable = true })

local icons = require('libs.icons')
require('custom.statusline').setup({
  ft_icon = function(ft) return Snacks.util.icon(ft, 'filetype') end,
})
require('custom.tabline').setup({
  hide_single_tab = true,
  on_close = function(buf_id) Snacks.bufdelete(buf_id) end,
  file_icons = function(name) return Snacks.util.icon(name, 'file') end,
  icons = { close = icons.basic.close, modify = icons.basic.modify }
})
-- Edit
require('custom.pairs').setup()
require('custom.surround').setup()
