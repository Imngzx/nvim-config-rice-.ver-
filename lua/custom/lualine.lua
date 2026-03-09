local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/nvim-lualine/lualine.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  -- event = { 'User', pattern = 'VeryLazy' },
  setup = function()
    require('lualine').setup({
      options = {
        theme = 'auto',
        section_separators = { left = '', right = '' },
        component_separators = { left = ' ', right = ' ' },
        -- Seperators :
        --  - default : "" "" Will only work for default Statusline Theme
        --  - "round" : "" "" Will only work for default and minimal Statusline Theme
        --  - "block" : "█" "█" Will only work for default and minimal Statusline Theme
        --  - "arrow" : "" "" Will only work for default Statusline Theme
        -- { left = '', right = '' },
        -- { left = '', right = '' }
        always_divide_middle = true,
        refresh_time = 1000,
      },
      sections = {
        lualine_a = {
          {
            'mode',


            --NOTE: this is for render only the N,V,I and etc
            -- fmt = function(str)
            --   return str:sub(1, 1)
            -- end,

            icon = '',
            padding = { left = 1, right = 1 },
          },
        },
        lualine_b = {
          {
            'diagnostics',
            sections = { 'error', 'warn', 'info', 'hint' },
            symbols = {
              error = ' ',
              warn = ' ',
              hint = ' ',
              info = ' ',
            },
          },
        },
        lualine_c = {
          'branch',
          {
            'diff',
            symbols = {
              added = ' ',
              modified = ' ',
              removed = ' ',
            },
          },
        },
        lualine_x = {
          -- Python Venv 虚拟环境显示
          {
            function()
              -- 只有当插件已经被加载过，才去获取 venv
              if not package.loaded['venv-selector'] then return '' end
              local venv = require('venv-selector').venv()
              if venv ~= nil then
                return string.match(venv, '([^/]+)$') or venv
              end
              return ''
            end,
            cond = function() return vim.bo.filetype == 'python' end,
            icon = '',
          },
          -- 文件类型
          {
            'lsp_status',
            icon = ' ',
          },
        },
        lualine_y = {
          {
            'location',
            icon = ' ',
          },
        },
        lualine_z = {
          function()
            local time = os.date('*t')
            local hour = time.hour
            local suffix = 'AM'
            if hour >= 12 then
              suffix = 'PM'
              if hour > 12 then
                hour = hour - 12
              end
            elseif hour == 0 then
              hour = 12
            end
            return string.format(' %02d:%02d %s', hour, time.min, suffix)
          end,
        },
      },
    })
  end
})
