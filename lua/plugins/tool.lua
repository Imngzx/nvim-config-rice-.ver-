local resonance = require('resonance')

-- [Key note] Load on VeryLazy
resonance.load({
  {
    'https://github.com/folke/which-key.nvim',
    event = { 'User', pattern = 'VeryLazy' },
    config = function()
      local wk = require('which-key')

      wk.setup({
        preset = 'modern', -- 可选: classic, modern, helix
        delay = function(ctx)
          return ctx.plugin and 0 or 250 -- 稍微延迟，避免快速盲打时屏幕闪烁
        end,
        win = {
          border = 'rounded', -- 与你全局的圆角风格统一
          padding = { 1, 2 }, -- 上下 1 行，左右 2 列的内边距，呼吸感更好
        },
      })

      -- 2. 🏷️ 注册你所有的快捷键前缀和精美图标
      wk.add({
        { '<leader>a', group = 'AI', icon = ' ' },
        { '<leader>b', group = 'Buffer', icon = '󰓩 ' },
        { '<leader>c', group = 'Code', icon = ' ' },
        { '<leader>d', group = 'Debug', icon = ' ' },
        { '<leader>e', group = 'Explorer', icon = '󰙅 ' },
        { '<leader>f', group = 'Find/File', icon = ' ' },
        { '<leader>g', group = 'Git', icon = '󰊢 ' },
        { '<leader>n', group = 'Minimap', icon = '🗺️ ' },
        { '<leader>p', group = 'Panel/Project', icon = '󰏖 ' },
        { '<leader>q', group = 'Quit', icon = '󰗼 ' },
        { '<leader>r', group = 'Run', icon = ' ' },
        { '<leader>s', group = 'Search', icon = '󰜎 ' },
        { '<leader>t', group = 'Translate', icon = ' ' },
        { '<leader>T', group = 'Telegram', icon = ' ' },
        { '<leader>u', group = 'UI/Toggles', icon = '󰙵 ' },

        { '[', group = 'Prev', icon = '󰒮 ' },
        { ']', group = 'Next', icon = '󰒭 ' },
        { 'g', group = 'Goto', icon = '󰜎 ' },
        { 's', group = 'Surround', icon = '󰑄 ' },
        { 'z', group = 'Fold', icon = '󱃅 ' },

        -- bpm tab
        { '<leader><tab>', group = 'Workspace/Tabs', icon = '󰓩 ' },
      })

      vim.keymap.set('n', '<leader>?',
        function() wk.show({ global = false }) end,
        { desc = 'Buffer local keymaps' }
      )
    end
  },

  {
    'https://github.com/nvim-mini/mini.diff',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local mini_diff = require('mini.diff')

      mini_diff.setup({
        view = {
          style = 'sign',
          signs = { add = '│', change = '│', delete = '│' },
        },
        mappings = {
          -- Apply hunks inside a visual/operator region
          apply = '<leader>gh',

          -- Reset hunks inside a visual/operator region
          reset = '<leader>gH',

          -- Hunk range textobject to be used inside operator
          -- Works also in Visual mode if mapping differs from apply and reset
          textobject = '<leader>gh',

          -- Go to hunk range in corresponding direction
          goto_first = '[H',
          goto_prev = '[h',
          goto_next = ']h',
          goto_last = ']H',
        },
      })
      vim.keymap.set('n', '<leader>go', function()
        mini_diff.toggle_overlay(0)
      end, { desc = 'Toggle diff' })
    end
  },

  {
    'https://github.com/Imngzx/ascetic.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    -- event = { 'User', pattern = 'VeryLazy' },
    config = function()
      local Ascetic = require('ascetic')

      Ascetic.setup({
        enabled = true,
        smart_j_k = true,
        threshold = 10,
        timeout = 2000,
        message = function(key)
          local insults = {
            j = 'Down down down... use `C-d` bro!',
            k = 'Up up up... use `C-u` instead!',
          }
          return insults[key] or ('Stop pressing `%s`!'):format(key)
        end,
      })
      vim.keymap.set('n', '<leader>ua', Ascetic.toggle, { desc = 'Toggle Ascetic' })
    end
  },
})
