local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/XXiaoA/atone.nvim',
  -- 只有在使用命令或快捷键时才会加载这个插件
  cmd = { 'Atone' },
  keys = {
    { 'n', '<leader>uu', '<cmd>Atone toggle<cr>', { desc = 'Toggle Undo Tree (Atone)' } },
  },
  setup = function()
    require('atone').setup({
      -- 下面都是默认可选配置，可根据喜好调整
      layout = {
        direction = 'left',
        width = 0.25, -- 如果小于 1 则视为屏幕宽度的百分比
      },
      diff_cur_node = {
        enabled = true,
        split_percent = 0.3,
      },
      marks = {
        persist = true, -- 保存书签，哪怕重启 Nvim 也不丢
      },
    })
  end
})
