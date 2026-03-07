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

-- require('plugins.suda')
require('custom.sudo')

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
require('custom.lualine')
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


if vim.g.neovide then
  vim.o.guifont =
  'JetBrainsMono Nerd Font:h14' -- Replace h14 with your desired font size remove :b for regular font
  vim.g.neovide_window_blurred = true
  -- vim.g.neovide_opacity = 0.93
  vim.g.neovide_floating_blur_amount_x = 3.0
  vim.g.neovide_floating_blur_amount_y = 3.0
  vim.g.neovide_refresh_rate = 75
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_hide_titlebar = true
  vim.g.neovide_padding_bottom = -2
  vim.g.neovide_floating_shadow = false
  vim.g.neovide_window_blurred = true
  vim.g.neovide_opacity = 0.8
  vim.g.neovide_normal_opacity = 0.8
  if vim.g.neovide then
    -- Running in Neovide → disable snacks scroll
    vim.g.snacks_scroll = false
  else
    -- Running in terminal → enable snacks scroll
    vim.g.snacks_scroll = true
  end
end
