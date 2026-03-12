-- [Startup]
require('custom.startup')


-- [Config]
require('config.options')
require('config.keymaps')
require('config.autocmds')


-- [Theme]
-- require('custom.theme').setup() -- theme must be set before plugins
require('custom.catppuccin') -- theme must be set before plugins


-- [Plugins & diy plugins]
--     [Treesitter]
require('plugins.treesitter')
require('plugins.treesitter-context')

--     [Rice]
require('plugins.ui')
require('plugins.tool')
require('plugins.markdown')
require('custom.todo').setup() --TODO:
local Snacks = require('plugins.snacks')
require('plugins.csvview')
require('custom.lualine')
require('custom.lsp-loading').setup()
require('custom.incline').setup()
require('custom.transparent').setup({ auto_enable = false })
local icons = require('libs.icons')
require('custom.tabline').setup({
  hide_single_tab = false,
  on_close = function(buf_id) Snacks.bufdelete(buf_id) end,
  file_icons = function(name) return Snacks.util.icon(name, 'file') end,
  icons = { close = icons.basic.close, modify = icons.basic.modify }
})

--     [coding]
require('plugins.lsp')
require('plugins.colorful-lsp-menu')
require('plugins.coderunner')
require('plugins.venv-selector')
require('plugins.dap')
require('plugins.AI')
-- Input method swtich for non-English users
require('plugins.im-select')

--     [Editing assistance]
require('custom.pairs').setup()
require('custom.surround').setup()
require('custom.word-jump')
require('custom.sudo') --current working-well version


-- [neovide]
require('config.neovide')


-- [Lazy-loading engine]
require('libs.lazy').trigger_verylazy()
