-- [Config]
require('config.options')
require('config.keymaps')
require('config.autocommands')

-- [Plugins]
-- require('custom.theme').setup() -- theme must be set before plugins
require('plugins.ui')
require('plugins.lsp')
require('plugins.tool')
require('plugins.snacks')

-- [Custom]
-- UI
require('custom.transparent').setup({ auto_enable = true })
require('custom.statusline')
require('custom.tabline').setup({ hide_single_tab = true })
-- Edit
-- require('custom.pairs').setup()
require('custom.surround').setup()
-- Tool
