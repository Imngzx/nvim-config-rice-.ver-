-- [Startup]
require('custom.startup')

-- [Config]
require('config.options')
require('config.keymaps')
require('config.autocmds')

-- [Theme]
require('custom.catppuccin') -- 主题必须最先加载，防止屏幕闪烁

-- ==========================================================
-- 🌟 第一梯队：必须同步加载的 UI 与核心组件
-- ==========================================================
local Snacks = require('plugins.snacks')
require('plugins.ui')
require('plugins.markdown')
require('plugins.csvview')
require('custom.incline').setup()
require('custom.transparent').setup({ auto_enable = false })

-- Tabline 必须同步，否则启动时顶部会突然闪现出标签栏
local icons = require('libs.icons')
require('custom.tabline').setup({
  hide_single_tab = false,
  -- 完美：支持擦除（wipe）以释放内存
  on_close = function(buf_id) Snacks.bufdelete(buf_id, { wipe = true }) end,
  file_icons = function(name) return Snacks.util.icon(name, 'file') end,
  icons = { close = icons.basic.close, modify = icons.basic.modify }
})

require('custom.lualine')

-- ==========================================================
-- 🌟 第二梯队：注册 Lazy-loading 监听器与核心文件钩子
-- ==========================================================
require('plugins.tool')
require('plugins.treesitter')
require('plugins.treesitter-context')
require('plugins.lsp')
require('plugins.colorful-lsp-menu')
require('plugins.coderunner')
require('plugins.venv-selector')
require('plugins.dap')
require('plugins.AI')
require('plugins.im-select')
require('config.neovide')

-- 👇 将依赖 BufRead/BufEnter 的功能放在这，确保拦截到第一个文件
require('custom.sudo')
require('custom.todo').setup()

-- ==========================================================
-- 🌟 第三梯队：利用 VeryLazy 彻底让出主线程的 DIY 功能
-- ==========================================================
-- 把纯快捷键、纯异步逻辑丢到后台去，实现真正的“秒开”！
vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  callback = function()
    require('custom.lsp-loading').setup()
    require('custom.pairs').setup()
    require('custom.surround').setup()
    require('custom.word-jump')
  end
})

-- [Lazy-loading engine] 触发器，拉起所有被标为 VeryLazy 的事件
require('libs.lazy').trigger_verylazy()
