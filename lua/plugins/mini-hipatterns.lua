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

    -- 🎨 3. 准备 TODO 关键字和专属颜色 (Catppuccin Mocha)
    local todo_keywords = {
      TODO = '#a6e3a1', -- Mocha Green (待办/新功能)
      FIXME = '#f38ba8', -- Mocha Red (修 Bug)
      NOTE = '#89b4fa', -- Mocha Blue (笔记/记录)
      WARN = '#fab387', -- Mocha Peach (警告/注意)
      HACK = '#f9e2af', -- Mocha Yellow (临时硬编码/魔法)
      PERF = '#cba6f7', -- Mocha Mauve (性能优化)
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

    -- 🚀 4. 循环注入 TODO 关键字高亮
    for kw, color in pairs(todo_keywords) do
      local hl_group = 'HandcraftedTodo_' .. kw

      -- 初始化高亮组（深色字体，背景为关键字颜色，加粗）
      vim.api.nvim_set_hl(0, hl_group, { fg = '#181825', bg = color, bold = true })

      -- 保证切换主题时颜色依然有效
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('HandcraftedTodoHL_' .. kw, { clear = true }),
        callback = function()
          vim.api.nvim_set_hl(0, hl_group, { fg = '#181825', bg = color, bold = true })
        end,
      })

      -- 将规则塞入 mini.hipatterns 引擎
      highlighters['todo_' .. kw:lower()] = {
        -- %f[%w] 代表单词边界，等同于 \C\<
        -- () 标记高亮的起始和结束位置
        pattern = '%f[%w]()' .. kw .. ':()',
        group = hl_group,
      }
    end

    hi.setup({
      highlighters = highlighters,
    })
  end
})
