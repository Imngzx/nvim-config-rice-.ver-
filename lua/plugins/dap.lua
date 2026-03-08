local lazy = require('libs.lazy')

-- [Debugger] Nvim-DAP 核心及其生态插件
lazy.load({
  -- 传入一个列表，同时拉取并加载所有相关插件
  plugin = {
    'https://github.com/mfussenegger/nvim-dap',
    'https://github.com/igorlfs/nvim-dap-view',
    'https://github.com/theHamsta/nvim-dap-virtual-text',
    'https://github.com/mfussenegger/nvim-dap-python',
  },
  event = { 'User', pattern = 'VeryLazy' },
  keys = {
    -- 📺 DAP View (UI)
    { 'n', '<leader>du', function() require('dap-view').toggle() end, { desc = 'Toggle Dap View' } },

    -- 🐍 DAP Python
    { 'n', '<localleader>pdt', function() require('dap-python').test_method() end, { desc = 'Debug Method (Python)' } },
    { 'n', '<localleader>pdc', function() require('dap-python').test_class() end, { desc = 'Debug Class (Python)' } },

    -- ⚙️ DAP Core
    { 'n', '<leader>dB', function()
      require('dap').set_breakpoint(vim.fn.input(
        'Breakpoint condition: '))
    end, { desc = 'Breakpoint condition' } },
    { 'n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = 'Toggle breakpoint' } },
    { 'n', '<leader>dc', function() require('dap').continue() end, { desc = 'Continue' } },
    { 'n', '<leader>dC', function() require('dap').run_to_cursor() end, { desc = 'Run to cursor' } },
    { 'n', '<leader>dg', function() require('dap').goto_() end, { desc = 'Go to line (no execute)' } },
    { 'n', '<leader>di', function() require('dap').step_into() end, { desc = 'Step into' } },
    { 'n', '<leader>dj', function() require('dap').down() end, { desc = 'Down' } },
    { 'n', '<leader>dk', function() require('dap').up() end, { desc = 'Up' } },
    { 'n', '<leader>dl', function() require('dap').run_last() end, { desc = 'Run last' } },
    { 'n', '<leader>do', function() require('dap').step_out() end, { desc = 'Step out' } },
    { 'n', '<leader>dO', function() require('dap').step_over() end, { desc = 'Step over' } },
    { 'n', '<leader>dp', function() require('dap').pause() end, { desc = 'Pause' } },
    { 'n', '<leader>dr', function() require('dap').repl.toggle() end, { desc = 'Toggle REPL' } },
    { 'n', '<leader>ds', function() require('dap').session() end, { desc = 'Session' } },
    { 'n', '<leader>dt', function() require('dap').terminate() end, { desc = 'Terminate' } },
    { 'n', '<leader>dw', function() require('dap.ui.widgets').hover() end, { desc = 'Widgets' } },
  },
  setup = function()
    -- 1. 🎨 定义行号栏图标 (原 init 部分)
    vim.fn.sign_define('DapBreakpoint',
      { text = ' ', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointCondition',
      { text = ' ', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
    vim.fn.sign_define('DapLogPoint',
      { text = ' ', texthl = 'DapLogPoint', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped',
      { text = ' ', texthl = 'DapBreakpointStopped', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointRejected',
      { text = ' ', texthl = 'DapBreakpointRejected', linehl = '', numhl = '' })

    -- 2. 🔌 启动附属插件 (原 opts 自动启动的部分)
    require('dap-view').setup()
    require('nvim-dap-virtual-text').setup({})
    require('dap-python').setup('python3', {})

    -- 3. ⚙️ 配置 DAP 适配器和语言 (原 config 部分)
    local dap = require('dap')

    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = 'codelldb',
        args = { '--port', '${port}' },
      },
    }

    dap.configurations.zig = {
      {
        type = 'codelldb',
        request = 'launch',
        name = 'Launch Zig',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/zig-out/bin/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = true,
        args = {},
      },
    }

    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp
  end
})
