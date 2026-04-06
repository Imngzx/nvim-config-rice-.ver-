local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/nvim-lualine/lualine.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  -- event = { 'User', pattern = 'VeryLazy' },
  setup = function()
    require('lualine').setup({
      options = {
        theme = 'auto',
        globalstatus = true,

        disabled_filetypes = {
          statusline = { 'snacks_picker_list', 'snacks_picker_input', 'snacks_dashboard', 'snacks_terminal', 'snacks_notif' },
          winbar = { 'snacks_picker_list', 'snacks_picker_input', 'snacks_dashboard', 'snacks_terminal', 'snacks_notif' },
        },
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
        -- update every minutes, matches our lualine's clock format
        -- able to save cpu and battery with this
        refresh_time = 60000,
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
              added = ' ',
              modified = ' ',
              removed = ' ',
            },
          },
        },
        lualine_x = {
          {
            function()
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
            local t = os.date('*t')
            local is_pm = t.hour >= 12
            local hour12 = t.hour % 12
            if hour12 == 0 then hour12 = 12 end -- 处理 0 点和 12 点

            return string.format(' %02d:%02d %s', hour12, t.min, is_pm and 'PM' or 'AM')
          end,
        },
      },
    })
  end
})
