require('custom.startup')
_G.start_time = vim.uv.hrtime()
-- [Config]
require('config.options')
require('config.keymaps')
require('config.autocmds')

--TODO:
require('custom.todo').setup()

-- Theme
-- require('custom.theme').setup() -- theme must be set before plugins
require('custom.catppuccin') -- theme must be set before plugins
-- [Plugins]
require('plugins.treesitter')
require('plugins.ui')
require('plugins.lsp')
require('plugins.colorful-lsp-menu')
require('plugins.tool')
require('plugins.markdown')
local Snacks = require('plugins.snacks')

-- Input method swtich for non-English users
-- 仅在非 Windows 系统（如 Linux/macOS）下加载 im-select
if vim.fn.has('win32') == 0 then
  require('plugins.im-select')
end

require('plugins.coderunner')
require('plugins.venv-selector')

require('plugins.treesitter-context')
require('plugins.csvview')
require('plugins.dap')

-- [Custom]
-- UI
-- require('custom.transparent').setup({ auto_enable = true })
-- Tools
local icons = require('libs.icons')

-- show statusline that placed at below (above cmdline)
-- minimal statusline
-- require('custom.statusline').setup({
--   hide_filename_by_ft = { snacks_picker_list = true },
--   icons = { branch = icons.git.branch }
-- })
-- lualine
require('custom.lualine')

--file name displays on top right
require('custom.incline').setup()

-- edit locked system files with sudo
require('custom.sudo') --current working-well version


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
