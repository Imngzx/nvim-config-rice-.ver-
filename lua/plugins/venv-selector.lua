local lazy = require('libs.lazy')

-- [Python Venv Selector]
-- 自动寻找并切换 Python 虚拟环境，原生集成 Snacks Picker
lazy.load({
  plugin = 'https://github.com/linux-cultist/venv-selector.nvim',
  -- 只有在打开 Python 文件时，或者手动输入命令时才加载，极致优化启动速度
  ft = 'python',
  cmd = { 'VenvSelect', 'VenvSelectCached' },
  keys = {
    -- 👇 修复点：将 '<cmd>VenvSelect<cr>' 改写为安全的 Lua 函数
    { 'n', '<leader>cv', function() vim.cmd('VenvSelect') end, { desc = 'Select Python Venv' } },
  },
  setup = function()
    require('venv-selector').setup({
      settings = {
        options = {
          notify_user_on_venv_activation = true, -- 切换成功后在右下角给个提示
        },
      },
      -- VenvSelector 最新版会自动检测你安装的 Picker，
      -- 因为你有 snacks.nvim，它会自动调用 snacks 来展示虚拟环境列表
    })
  end
})
