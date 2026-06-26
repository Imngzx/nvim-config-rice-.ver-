vim.api.nvim_create_user_command('PickColor', function()
  local color_lib = require('custom.color-list')
  local palette = color_lib.get_palette_indexed()

  local ok, snacks = pcall(require, 'snacks')
  if not ok then return end

  local function get_contrast_color(hex_str)
    if not hex_str or #hex_str ~= 7 then return '#1e1e2e' end
    local r, g, b = tonumber(hex_str:sub(2, 3), 16), tonumber(hex_str:sub(4, 5), 16),
      tonumber(hex_str:sub(6, 7), 16)
    return (0.299 * r + 0.587 * g + 0.114 * b) > 128 and '#1e1e2e' or '#cdd6f4'
  end

  local items = {}
  for i = 1, #palette do
    local color = palette[i]
    local hl_fg = 'VibeColorFg_' .. color.name
    local hl_bg = 'VibeColorBg_' .. color.name

    -- 文字颜色
    vim.api.nvim_set_hl(0, hl_fg, { fg = color.hex })
    vim.api.nvim_set_hl(0, hl_bg, { fg = get_contrast_color(color.hex), bg = color.hex, bold = true })

    table.insert(items, {
      text = color.name .. ' ' .. color.hex,
      color_data = color,
      hl_fg = hl_fg,
      hl_bg = hl_bg,
      idx = i,
    })
  end

  snacks.picker({
    title = ' 🎨 Select Vibe Color to Copy ',
    items = items,
    layout = {
      layout = {
        backdrop = 60,
        width = 0.45,
        height = 0.65,
        border = 'rounded',
        box = 'vertical',
        { win = 'input', height = 1, border = 'bottom' },
        { win = 'list', border = 'none' },
      }
    },
    format = function(item, _)
      local c = item.color_data
      return {
        { string.format(' %-7s ', c.hex), item.hl_bg }, -- 左侧：包裹 HEX 的彩色实心方块 (保留)
        { '  ', 'Normal' }, -- 间距
        { string.format('%-19s', c.name), 'Normal' }, -- 中间：颜色名 (💡 修改为 Normal，不上色)
        { c.rgb, 'Comment' }, -- 右侧：仅保留 RGB (💡 用 Comment 颜色，低调且清晰)
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        local selected_hex = item.color_data.hex
        vim.fn.setreg('+', selected_hex)
        vim.fn.setreg('"', selected_hex)
        vim.notify('Copied: ' .. selected_hex .. '\nName: ' .. item.color_data.name,
          vim.log.levels.INFO, { title = 'Color Picker' })
      end
    end,
  })
end, {})
