-- [Startup]
require('custom.startup')

-- [Config]
require('config.options')
require('config.keymaps')
require('config.autocmds')

-- [Theme]
-- load theme first to avoid flickering
require('plugins.catppuccin')
-- require('custom.theme')

-- load core ui elements at the same time
local Snacks = require('plugins.snacks')
require('plugins.ui')
require('plugins.markdown')
require('plugins.csvview')
require('custom.incline').setup()
require('custom.transparent').setup({ auto_enable = false })

local icons = require('libs.icons')
require('custom.tabline').setup({
  hide_single_tab = false,
  -- use wipe for better ram usage
  on_close = function(buf_id) Snacks.bufdelete(buf_id, { wipe = true }) end,
  file_icons = function(name) return Snacks.util.icon(name, 'file') end,
  icons = { close = icons.basic.close, modify = icons.basic.modify }
})

require('plugins.heirline')
-- require('custom.statusline').setup({
--   git_cache_setup = { get_git_root = Snacks.git.get_root },
--   hide_filename_by_ft = { snacks_picker_list = true },
--   icons = { branch = icons.git.branch }
-- })

require('custom.session').setup()
require('plugins.tool')
require('plugins.treesitter')
require('plugins.treesitter-context')
require('plugins.lsp')
require('plugins.colorful-lsp-menu')
require('custom.coderunner').setup()
require('plugins.venv-selector')
require('plugins.dap')
require('plugins.AI')
if not require('libs.utils').is_windows() then
  require('custom.language-switcher').setup()
end
-- require('plugins.im-select') -- NOTE: comment this if you encounter any erro on windows os
require('config.neovide')

require('custom.sudo')
require('custom.todo').setup()

-- [git]
require('custom.git').setup({
  stage_action = Snacks.picker.actions.git_stage,
  get_git_root = Snacks.git.get_root
})
require('custom.git-blame').setup({
  enabled = true,
  message_template = '  󰈔 <summary>,  <author> (<date>)',
  date_format = '%r',
  delay = 1000,
  max_summary_length = 30,
  get_git_root = Snacks.git.get_root
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  callback = function()
    require('custom.lsp-loading').setup()
    require('custom.pairs').setup()
    require('custom.surround').setup()

    -- you can try it out if you want ฅ₍^•⩊ •マⳊ
    require('custom.word-jump')

    require('plugins.atone')
    require('plugins.flash')
    require('plugins.minimap')
    require('plugins.mini-hipatterns')
  end
})

-- [Lazy-loading engine]
require('libs.lazy').trigger_verylazy()
