-- =====================================================================
-- 🎵 Bootstrap Resonance.nvim
-- =====================================================================
local plugin_url = 'https://github.com/Imngzx/resonance.nvim'
local pack_path = vim.fn.stdpath('data') .. '/site/pack/core/opt/resonance.nvim'

if not vim.uv.fs_stat(pack_path) then
  vim.notify('󱑽 Resonating (Downloading resonance.nvim)...', vim.log.levels.INFO)
  vim.system({ 'git', 'clone', '--filter=blob:none', plugin_url, '--branch=main', pack_path }):wait()
end

vim.opt.rtp:prepend(pack_path)

vim.cmd('packadd resonance.nvim')

-- =====================================================================
-- 🚀 Configuration
-- =====================================================================
local resonance = require('resonance')

resonance.setup({
  ui = {
    border = 'rounded', -- 边框样式 (可选: "none", "single", "double", "rounded", "solid", "shadow")
    width = 0.65, -- 浮窗宽度（占屏幕百分比，0.65 = 65%）
    height = 0.75, -- 浮窗高度（占屏幕百分比，0.75 = 75%）
  }
})

-- UI keymap binding
vim.keymap.set('n', '<leader>pL', resonance.open_ui, { desc = 'Resonance UI' })

--plugins

-- [Theme]
-- load theme first to avoid flickering
require('plugins.catppuccin')

-- load core ui elements at the same time
local Snacks = require('plugins.snacks')
require('plugins.cmdline')
require('plugins.ui')

-- local icons = require('libs.icons')
-- require('custom.tabline').setup({
--   hide_single_tab = false,
--   -- use wipe for better ram usage
--   on_close = function(buf_id)
--     local ok, bpm = pcall(require, 'bpm')
--     if ok then
--       bpm.detach(buf_id)
--     else
--       Snacks.bufdelete(buf_id, { wipe = true })
--     end
--   end,
--   file_icons = function(name) return Snacks.util.icon(name, 'file') end,
--   icons = { close = icons.basic.close, modify = icons.basic.modify }
-- })

require('plugins.tool')
require('custom.sudo')

-- misc
require('plugins.discord')

-- NOTE: the reson I wrap my plugins with this block is because the mechanics of luajit
-- although resonance.nvim will blocks luajit to require the plugin until resonance sends it to rtp
-- but luajit will still read the config file (not the plugin)
-- this will cause some slow startup time
-- It doesnt meant that resonance is not lazy-loading

vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  callback = function()
    -- restore session
    require('custom.session').setup()
    require('custom.workspace').setup()

    -- coding
    require('plugins.treesitter')
    require('plugins.treesitter-context')
    require('plugins.lsp')
    require('plugins.colorful-lsp-menu')
    require('plugins.ufo')
    require('custom.pairs').setup()
    require('custom.surround').setup()
    require('custom.word-jump')
    require('plugins.flash')

    -- UI
    require('plugins.heirline')
    -- require('custom.statusline').setup({
    --   git_cache_setup = { get_git_root = Snacks.git.get_root },
    --   hide_filename_by_ft = { snacks_picker_list = true },
    --   icons = { branch = icons.git.branch }
    -- })
    require('custom.incline').setup()
    require('custom.lsp-loading').setup()
    require('custom.transparent').setup({ auto_enable = false })
    require('plugins.minimap')
    require('plugins.mini-hipatterns')
    require('plugins.markdown')
    require('plugins.csvview')

    -- Util
    require('custom.coderunner').setup()
    require('plugins.venv-selector')
    require('plugins.dap')
    require('plugins.jisho')
    require('plugins.AI')
    require('plugins.atone')
    if not require('libs.utils').is_windows() then
      require('custom.language-switcher').setup()
      require('plugins.telegram')
    end
    require('config.neovide')
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

    vim.schedule(function()
      local api = vim.api
      local fn = vim.fn
      local bufs = api.nvim_list_bufs()
      for i = 1, #bufs do
        local buf = bufs[i]
        local name = api.nvim_buf_get_name(buf)
        if api.nvim_buf_is_loaded(buf) and name ~= '' then
          if fn.filereadable(name) == 1 then
            pcall(api.nvim_exec_autocmds, 'BufReadPre', { buf = buf, modeline = false })
            pcall(api.nvim_exec_autocmds, 'BufReadPost', { buf = buf, modeline = false })
          else
            pcall(api.nvim_exec_autocmds, 'BufNewFile', { buf = buf, modeline = false })
          end
          pcall(api.nvim_exec_autocmds, 'FileType', { buf = buf, modeline = false })
        end
      end
    end)
  end
})


-- NOTE: must put this at the end of your init.lua!
resonance.trigger_verylazy()
