local resonance = require('resonance')

resonance.load({
  'https://github.com/nvim-mini/mini.hipatterns',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    local hi = require('mini.hipatterns')

    -- 🛑 1. 定义黑名单：在这些文件类型中，不使用颜色渲染
    local exclude_ft = { 'lua' }

    -- 🔧 2. 获取官方的 hex_color 高亮器配置并劫持
    local hex_color_hl = hi.gen_highlighter.hex_color({ priority = 2000 })
    local orig_hex_pattern = hex_color_hl.pattern
    hex_color_hl.pattern = function(buf_id)
      if vim.tbl_contains(exclude_ft, vim.bo[buf_id].filetype) then return nil end
      return type(orig_hex_pattern) == 'function' and orig_hex_pattern(buf_id) or orig_hex_pattern
    end

    -- 🎨 3. 准备 TODO 关键字、专属颜色 (Catppuccin Mocha) 以及 Nerd Font 图标！
    local todo_keywords = {
      TODO = { group = 'DiagnosticOk', icon = ' ' }, -- TODO:
      FIXME = { group = 'DiagnosticError', icon = ' ' }, -- FIXME:
      NOTE = { group = 'DiagnosticInfo', icon = ' ' }, -- NOTE:
      WARN = { group = 'DiagnosticWarn', icon = ' ' }, -- WARN:
      HACK = { group = 'MatchParen', icon = ' ' }, -- HACK:
      PERF = { group = 'DiagnosticHint', icon = '󰅒 ' }, -- PERF:
    }

    local highlighters = {
      -- 注入劫持后的 Hex 颜色高亮
      hex_color = hex_color_hl,
      shorthand = {
        pattern = function(buf_id)
          if vim.tbl_contains(exclude_ft, vim.bo[buf_id].filetype) then return nil end
          return '()#%x%x%x()%f[^%x%w]'
        end,
        group = function(_, _, data)
          local match = data.full_match
          local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
          local full_hex = '#' .. r .. r .. g .. g .. b .. b
          return MiniHipatterns.compute_hex_color_group(full_hex, 'bg')
        end,
        extmark_opts = { priority = 2000 },
      },
    }

    for kw, config in pairs(todo_keywords) do
      local hl_group = 'HandcraftedTodo_' .. kw
      local sign_hl_group = 'HandcraftedTodoSign_' .. kw

      local function set_hls()
        -- 获取当前主题的背景色，用于反色
        local ok_bg, hl_norm = pcall(vim.api.nvim_get_hl, 0, { name = 'Normal', link = false })
        local base_bg = (ok_bg and hl_norm.bg) and string.format('#%06x', hl_norm.bg) or '#1e1e2e'

        for kw, config in pairs(todo_keywords) do
          local hl_group = 'HandcraftedTodo_' .. kw
          local sign_hl_group = 'HandcraftedTodoSign_' .. kw

          -- 动态获取组颜色
          local ok, hl_def = pcall(vim.api.nvim_get_hl, 0, { name = config.group, link = false })
          local fg_color = (ok and hl_def.fg) and string.format('#%06x', hl_def.fg) or '#ffffff'

          -- 设置：背景为组颜色，前景为普通背景色 (实现实心方块效果)
          vim.api.nvim_set_hl(0, hl_group, { fg = base_bg, bg = fg_color, bold = true })
          vim.api.nvim_set_hl(0, sign_hl_group, { fg = fg_color, bg = 'NONE', bold = true })
        end
      end

      -- 初始化与主题切换绑定
      set_hls()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('HandcraftedTodoHL', { clear = true }),
        callback = set_hls,
      })

      -- 将规则塞入 mini.hipatterns 引擎
      highlighters['todo_' .. kw:lower()] = {
        -- %f[%w] 代表单词边界，等同于 \C\<
        pattern = '%f[%w]()' .. kw .. ':()',
        group = hl_group,

        extmark_opts = {
          sign_text = config.icon, -- 左侧图标
          sign_hl_group = sign_hl_group, -- 左侧图标的颜色
          priority = 2000,
        },
      }
    end

    hi.setup({
      highlighters = highlighters,
    })
  end
})
