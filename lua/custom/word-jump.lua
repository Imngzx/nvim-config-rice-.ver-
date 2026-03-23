local M = {}
local ns_id = vim.api.nvim_create_namespace('flash_diy')

local config = {
  labels = 'asdfghjklqwertyuiopzxcvbnmASDFGHJKLQWERTYUIOPZXCVBNM1234567890',
}

local function init_hl()
  local set_hl = vim.api.nvim_set_hl
  -- Backdrop: Dim unrelated text
  set_hl(0, 'FlashDiyBackdrop', { fg = '#545c7e', default = false })
  -- Match: Highlight targeted characters
  set_hl(0, 'FlashDiyMatch', { fg = '#c0caf5', bg = '#3d59a1', bold = true, default = false })
  -- Label: Jump indicators
  set_hl(0, 'FlashDiyLabel', { fg = '#15161e', bg = '#ff007c', bold = true, default = false })
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('FlashDiyHL', { clear = true }),
  callback = init_hl,
})

init_hl()

local function cleanup()
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  vim.cmd('redraw')
end

local function get_matches(target_char)
  local matches = {}
  local win_info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local top = win_info.topline
  local bot = win_info.botline

  local lines = vim.api.nvim_buf_get_lines(0, top - 1, bot, false)

  for i, line in ipairs(lines) do
    local lnum = top + i - 1
    local col = 1
    while true do
      -- Plain text search
      local s, e = line:find(target_char, col, true)
      if not s then break end

      table.insert(matches, { lnum, s })
      col = e + 1
      if #matches >= #config.labels then return matches end
    end
  end
  return matches
end

local function render(matches, top, bot)
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

  -- Apply backdrop filter to viewport
  local lines = vim.api.nvim_buf_get_lines(0, top - 1, bot, false)
  for i, line in ipairs(lines) do
    local lnum = top + i - 2
    if #line > 0 then
      vim.api.nvim_buf_set_extmark(0, ns_id, lnum, 0, {
        end_col = #line,
        hl_group = 'FlashDiyBackdrop',
        priority = 4000,
      })
    end
  end

  local label_map = {}
  for i, m in ipairs(matches) do
    local char = config.labels:sub(i, i)
    label_map[char] = m

    local lnum = m[1] - 1
    local start_col = m[2] - 1
    local end_col = m[2]

    -- Highlight match
    vim.api.nvim_buf_set_extmark(0, ns_id, lnum, start_col, {
      end_col = end_col,
      hl_group = 'FlashDiyMatch',
      priority = 5000,
    })

    -- Inline virtual text for labels
    vim.api.nvim_buf_set_extmark(0, ns_id, lnum, end_col, {
      virt_text = { { char, 'FlashDiyLabel' } },
      virt_text_pos = 'inline',
      priority = 6000,
    })
  end

  vim.cmd('redraw')
  return label_map
end

function M.jump()
  print('⚡ Flash ❯  ')
  local ok, target_char = pcall(vim.fn.getcharstr)

  if not ok or not target_char or target_char == '' or target_char:byte() == 27 then
    cleanup()
    return
  end

  local matches = get_matches(target_char)

  if #matches == 0 then
    cleanup()
    return
  elseif #matches == 1 then
    -- Jump immediately if single match found
    cleanup()
    vim.api.nvim_win_set_cursor(0, { matches[1][1], matches[1][2] - 1 })
    return
  end

  local win_info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local label_map = render(matches, win_info.topline, win_info.botline)

  print('⚡ Flash ❯  ')
  local ok_lbl, label_char = pcall(vim.fn.getcharstr)
  cleanup()

  if not ok_lbl or not label_char or label_char == '' or label_char:byte() == 27 then
    return
  end

  local target = label_map[label_char]
  if target then
    vim.api.nvim_win_set_cursor(0, { target[1], target[2] - 1 })
  end
end

vim.keymap.set('n', 'f', M.jump, { desc = 'DIY Flash Jump' })

return M
