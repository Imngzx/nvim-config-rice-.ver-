-- Auto switch input method

local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/keaising/im-select.nvim',
  -- 当打开已存在文件或新建文件时加载
  event = { 'InsertEnter' },
  -- 如果你想极致一点，可以改成 event = 'InsertEnter'，只有你按下 i 准备打字时才加载
  setup = function()
    require('im_select').setup({
      -- 这些是插件原本的配置
      set_default_events = { 'VimEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave' },
      set_previous_events = { 'InsertEnter' },
      keep_quiet_on_no_binary = false,
      async_switch_im = true,
    })
  end
})
