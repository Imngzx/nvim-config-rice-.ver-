local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/nvim-mini/mini.hipatterns',
  event = { 'BufReadPost', 'BufNewFile' },
  setup = function()
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
      TODO = { color = '#a6e3a1', icon = ' ' }, -- Mocha Green (待办/新功能)
      FIXME = { color = '#f38ba8', icon = ' ' }, -- Mocha Red (修 Bug)
      NOTE = { color = '#89b4fa', icon = ' ' }, -- Mocha Blue (笔记/记录)
      WARN = { color = '#fab387', icon = ' ' }, -- Mocha Peach (警告/注意)
      HACK = { color = '#f9e2af', icon = ' ' }, -- Mocha Yellow (临时硬编码/魔法)
      PERF = { color = '#cba6f7', icon = '󰅒 ' }, -- Mocha Mauve (性能优化)
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
        vim.api.nvim_set_hl(0, hl_group, { fg = '#181825', bg = config.color, bold = true })
        vim.api.nvim_set_hl(0, sign_hl_group, { fg = config.color, bg = 'NONE', bold = true })
      end

      set_hls()

      -- 保证切换主题时颜色依然有效
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('HandcraftedTodoHL_' .. kw, { clear = true }),
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
