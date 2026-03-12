local M = {}
local ns_id = vim.api.nvim_create_namespace('flash_diy')

local config = {
  labels = 'asdfghjklqwertyuiopzxcvbnm',
  hl_match = 'Search',
  hl_label = 'ErrorMsg',
}

local function cleanup()
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  vim.cmd('redraw')
end

local function get_matches(pattern)
  local matches = {}
  local win_info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local top = win_info.topline
  local bot = win_info.botline

  -- 👇 性能修复：一次性把视口的所有行全部抽出到内存中，避免在 Lua 循环里反复跨 C API 边界
  local lines = vim.api.nvim_buf_get_lines(0, top - 1, bot, false)

  for i, line in ipairs(lines) do
    local lnum = top + i - 1
    local col = 1
    while true do
      local s, e = line:find(pattern, col, true)
      if not s then break end
      table.insert(matches, { lnum, s })
      col = e + 1
      if #matches >= #config.labels then return matches end -- 达到上限尽早退出
    end
  end
  return matches
end

local function render(matches)
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  local label_map = {}

  for i, m in ipairs(matches) do
    local char = config.labels:sub(i, i)
    label_map[char] = m

    vim.api.nvim_buf_add_highlight(0, ns_id, config.hl_match, m[1] - 1, m[2] - 1, m[2])

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

function M.jump()
  local pattern = ''
  print('⚡ Flash ❯  ')

  while true do
    local ok, char = pcall(vim.fn.getcharstr)
    if not ok then
      cleanup()
      print('Cancelled')
      break
    end
    local code = char:byte()

    if code == 27 then
      cleanup()
      print('Cancelled')
      break
    end

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

    if code >= 32 and code <= 126 then
      pattern = pattern .. char
      local matches = get_matches(pattern)

      if #matches == 0 then
        cleanup()
        print('No matches for: ' .. pattern)
        break
      elseif #matches == 1 then
        cleanup()
        vim.api.nvim_win_set_cursor(0, { matches[1][1], matches[1][2] - 1 })
        break
      else
        render(matches)
        print('⚡ Flash ❯  ' .. pattern)
      end
    else
      cleanup()
      break
    end
  end
end

vim.keymap.set('n', 'f', M.jump, { desc = 'DIY Flash Jump' })

return M
