local M = {}
local ns_id = vim.api.nvim_create_namespace('flash_diy')

-- === 配置与样式 ===
local config = {
  labels = 'asdfghjklqwertyuiopzxcvbnm', -- 标签池
  hl_match = 'Search', -- 匹配项背景
  hl_label = 'ErrorMsg', -- 标签颜色 (建议加粗显眼)
}

-- 清理现场
local function cleanup()
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  vim.cmd('redraw')
end

-- 获取当前视口的匹配项
local function get_matches(pattern)
  local matches = {}
  local win_info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local top = win_info.topline
  local bot = win_info.botline

  -- 简单的正则搜索
  for lnum = top, bot do
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ''
    local col = 1
    while true do
      local s, e = line:find(pattern, col, true) -- true 代表简单搜索而非正则
      if not s then break end
      table.insert(matches, { lnum, s })
      col = e + 1
      if #matches >= #config.labels then break end -- 数量上限
    end
  end
  return matches
end

-- 渲染标签和高亮
local function render(matches)
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  local label_map = {}

  for i, m in ipairs(matches) do
    local char = config.labels:sub(i, i)
    label_map[char] = m

    -- 1. 高亮匹配到的字符背景
    vim.api.nvim_buf_add_highlight(0, ns_id, config.hl_match, m[1] - 1, m[2] - 1, m[2])

    -- 2. 在字符上方覆盖显示 Label (Nerd Font 加持)
    vim.api.nvim_buf_set_extmark(0, ns_id, m[1] - 1, m[2] - 1, {
      virt_text = { { char:upper(), config.hl_label } },
      virt_text_pos = 'overlay',
      hl_mode = 'combine',
      priority = 10000,
    })
  end
  vim.cmd('redraw')
  return label_map
end

-- 主函数
function M.jump()
  local pattern = ''
  print('Flash -> ')

  while true do
    local char = vim.fn.getcharstr()
    local code = char:byte()

    -- 处理特殊按键 (Esc = 27, Backspace = 8/128)
    if code == 27 then
      cleanup()
      print('Cancelled')
      break
    end

    -- 如果输入的是标签池里的字符，且当前有匹配，则跳转
    if #pattern > 0 then
      local matches = get_matches(pattern)
      local label_map = render(matches)

      if label_map[char:lower()] then
        local target = label_map[char:lower()]
        cleanup()
        vim.api.nvim_win_set_cursor(0, { target[1], target[2] - 1 })
        break
      end
    end

    -- 更新搜索模式 (只处理普通字符)
    if code >= 32 and code <= 126 then
      pattern = pattern .. char
      local matches = get_matches(pattern)

      if #matches == 0 then
        cleanup()
        print('No matches for: ' .. pattern)
        break
      elseif #matches == 1 then
        -- 只有一个匹配时直接跳
        cleanup()
        vim.api.nvim_win_set_cursor(0, { matches[1][1], matches[1][2] - 1 })
        break
      else
        render(matches)
        print('⚡ Flash ❯  ' .. pattern)
      end
    else
      -- 其他非法输入直接退出
      cleanup()
      break
    end
  end
end

-- 绑定快捷键 (比如 's')
vim.keymap.set('n', 'f', M.jump, { desc = 'DIY Flash Jump' })

return M
