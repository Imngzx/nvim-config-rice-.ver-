-- [Config]
require('config.options')
require('config.keymaps')
require('config.autocmds')
-- Theme
-- require('custom.theme').setup() -- theme must be set before plugins
require('custom.catppuccin') -- theme must be set before plugins
-- [Plugins]
require('plugins.ui')
require('plugins.lsp')
require('plugins.colorful-lsp-menu')
require('plugins.tool')
require('plugins.markdown')
local Snacks = require('plugins.snacks')
-- Input method swtich for non-English users
require('plugins.im-select')
require('plugins.coderunner')
require('plugins.venv-selector')

-- Write file with sudo privileges
-- require('plugins.suda') --deleted plugin

require('plugins.treesitter-context')
require('plugins.csvview')
require('plugins.dap')

-- [Custom]
-- UI
-- require('custom.transparent').setup({ auto_enable = true })
-- Tools
local icons = require('libs.icons')
-- require('custom.statusline').setup({
--   git_cache_setup = { get_git_root = Snacks.git.get_root },
--   hide_filename_by_ft = { snacks_picker_list = true },
--   icons = { branch = icons.git.branch }
-- })

-- edit locked system files with sudo
require('custom.sudo') --current working-well version

-- show statusline that placed at below (above cmdline)
require('custom.lualine')

--word jumping that similar as folke/flash.nvim
require('custom.word-jump')

require('custom.tabline').setup({
  hide_single_tab = true,
  on_close = function(buf_id) Snacks.bufdelete(buf_id) end,
  file_icons = function(name) return Snacks.util.icon(name, 'file') end,
  icons = { close = icons.basic.close, modify = icons.basic.modify }
})
-- Edit
require('custom.pairs').setup()
require('custom.surround').setup()

-- Trigger VeryLazy event after all are loaded
require('libs.lazy').trigger_verylazy()

--lsp loading
require('custom.lsp-loading')

--neovide
require('config.neovide')
