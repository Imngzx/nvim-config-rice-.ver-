local api = vim.api
local str_find = string.find
local str_sub = string.sub
local buf_get_lines = api.nvim_buf_get_lines
local buf_set_text = api.nvim_buf_set_text
local win_get_cursor = api.nvim_win_get_cursor

local markdown_loaded = vim.b.markdown_loaded
if markdown_loaded then return end
vim.b.markdown_loaded = true

require('libs.spell').setup()

local PATTERN_UNORDERED = '^%s*>?[%s>]*[%*%-%+]%s+%[().()%]'
local PATTERN_ORDERED = '^%s*>?[%s>]*%d+%.%s+%[().()%]'
local PATTERN_LIST_UNORDERED = '^%s*>?[%s>]*[%*%-%+]%s+()()'
local PATTERN_LIST_ORDERED = '^%s*>?[%s>]*%d+%.%s+()()'

local NEXT_STATE_MAP = {
  [' '] = '/',
  ['/'] = 'x',
  ['x'] = '-',
  ['-'] = ' ',
}

local function get_checkbox_pos(line)
  local _, _, p_start, p_end = str_find(line, PATTERN_UNORDERED)
  if p_start then return p_start, p_end end
  _, _, p_start, p_end = str_find(line, PATTERN_ORDERED)
  return p_start, p_end
end

local function get_list_pos(line)
  local _, _, l_start = str_find(line, PATTERN_LIST_UNORDERED)
  if l_start then return l_start end
  _, _, l_start = str_find(line, PATTERN_LIST_ORDERED)
  return l_start
end

local function set_checkbox(new_state)
  local row = win_get_cursor(0)[1] - 1
  local line = buf_get_lines(0, row, row + 1, false)[1]
  if not line or line == '' then return end

  local pos_start, pos_end = get_checkbox_pos(line)

  if pos_start then
    buf_set_text(0, row, pos_start - 1, row, pos_end - 1, { new_state })
  else
    local l_start = get_list_pos(line)
    if l_start then
      buf_set_text(0, row, l_start - 1, row, l_start - 1, { '[' .. new_state .. '] ' })
    end
  end
end

local function cycle_checkbox()
  local row = win_get_cursor(0)[1] - 1
  local line = buf_get_lines(0, row, row + 1, false)[1]
  if not line or line == '' then return end

  local pos_start = get_checkbox_pos(line)

  if pos_start then
    local current_state = str_sub(line, pos_start, pos_start)
    local new_state = NEXT_STATE_MAP[current_state] or ' '
    buf_set_text(0, row, pos_start - 1, row, pos_start, { new_state })
  else
    local l_start = get_list_pos(line)
    if l_start then
      buf_set_text(0, row, l_start - 1, row, l_start - 1, { '[ ] ' })
    end
  end
end

local map = vim.keymap.set

map('n', '<leader>cc', cycle_checkbox, {
  buf = 0,
  silent = true,
  desc = 'Cycle Checkbox ( / x - )'
})

local states = {
  x = { char = 'x', desc = 'Done [x]' },
  d = { char = '-', desc = 'Dropped/Cancelled [-]' },
  p = { char = '/', desc = 'In Progress [/]' },
  i = { char = '!', desc = 'Important [!]' },
  q = { char = '?', desc = 'Question [?]' },
  s = { char = '<', desc = 'Scheduled [<]' },
  f = { char = '>', desc = 'Forwarded [>]' },
  c = { char = ' ', desc = 'Clear [ ]' },
}

for key, info in pairs(states) do
  map('n', '<leader>ct' .. key, function()
    set_checkbox(info.char)
  end, { buf = 0, silent = true, desc = 'Task: ' .. info.desc })
end

require('custom.md-paste-image').setup({
  img_dir = '_res',
  auto_paste = true,
})
