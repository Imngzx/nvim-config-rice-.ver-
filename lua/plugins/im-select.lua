-- Auto switch input method
local lazy = require('libs.lazy')

local is_windows = vim.uv.os_uname().sysname:match('Windows')
local is_linux = vim.uv.os_uname().sysname == 'Linux'

-- im-select only makes sense on Windows (AIMSwitcher) and Linux (fcitx5)
-- macOS uses im-select binary (not configured here)
if not is_windows and not is_linux then return end

lazy.load({
  plugin = 'https://github.com/keaising/im-select.nvim',
  event = { 'InsertEnter' },
  setup = function()
    if is_windows then
      require('im_select').setup({
        default_im_select = '0', -- 0 = English/IME off in AIMSwitcher
        default_command = { 'AIMSwitcher.exe', '--imm' },
        set_default_events = { 'VimEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave' },
        set_previous_events = { 'InsertEnter' },
        keep_quiet_on_no_binary = false,
        async_switch_im = false, -- Windows IMM 不支持异步
      })
    elseif is_linux then
      require('im_select').setup({
        set_default_events = { 'VimEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave' },
        set_previous_events = { 'InsertEnter' },
        keep_quiet_on_no_binary = false,
        async_switch_im = true,
      })
    end
  end
})
