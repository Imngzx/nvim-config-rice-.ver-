local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/nvim-mini/mini.hipatterns',
  event = { 'BufReadPost', 'BufNewFile' },
  setup = function()
    local hi = require('mini.hipatterns')

    -- 🛑 1. 定义黑名单：在这些文件类型中，不使用 mini.hipatterns 渲染颜色
    -- （lua 交给 lua_ls 处理，以后如果有其他不需要的也可以加在这里）
    local exclude_ft = { 'lua' }

    -- 🔧 2. 获取官方的 hex_color 高亮器配置
    local hex_color_hl = hi.gen_highlighter.hex_color({ priority = 2000 })

    -- 🛡️ 3. 劫持原有的 pattern，加入拦截逻辑
    local orig_hex_pattern = hex_color_hl.pattern
    hex_color_hl.pattern = function(buf_id)
      -- 如果当前文件类型在黑名单里，直接返回 nil，瞬间阻断正则扫描！
      if vim.tbl_contains(exclude_ft, vim.bo[buf_id].filetype) then
        return nil
      end
      return type(orig_hex_pattern) == 'function' and orig_hex_pattern(buf_id) or orig_hex_pattern
    end

    hi.setup({
      highlighters = {
        -- 应用劫持后的标准 6 位 Hex 颜色高亮
        hex_color = hex_color_hl,

        -- 简写版 3 位 Hex (#RGB) 颜色高亮
        shorthand = {
          pattern = function(buf_id)
            -- 同样的拦截逻辑
            if vim.tbl_contains(exclude_ft, vim.bo[buf_id].filetype) then
              return nil
            end
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
      },
    })
  end
})
