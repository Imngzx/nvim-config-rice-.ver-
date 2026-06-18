local api = vim.api
local str_find = string.find
local str_sub = string.sub
local buf_get_lines = api.nvim_buf_get_lines
local buf_set_text = api.nvim_buf_set_text
local win_get_cursor = api.nvim_win_get_cursor
local markdown_loaded = vim.b.markdown_loaded

if markdown_loaded then return end
markdown_loaded = true

require('libs.spell').setup()

local PATTERN_UNORDERED = '^%s*>?[%s>]*[%*%-%+]%s+%[()[%sXx]()%]'
local PATTERN_ORDERED = '^%s*>?[%s>]*%d+%.%s+%[()[%sXx]()%]'

local function toggle_checkbox()
  local row = win_get_cursor(0)[1] - 1
  local line = buf_get_lines(0, row, row + 1, false)[1]
  if not line or line == '' then return end

  local _, _, pos_start, _ = str_find(line, PATTERN_UNORDERED)
  if not pos_start then
    _, _, pos_start, _ = str_find(line, PATTERN_ORDERED)
  end

  if pos_start then
    local current_state = str_sub(line, pos_start, pos_start)

    local new_state = (current_state == ' ' and 'x' or ' ')

    buf_set_text(0, row, pos_start - 1, row, pos_start, { new_state })
  end
end

vim.keymap.set('n', '<leader>ct', toggle_checkbox, {
  buffer = true,
  silent = true,
  desc = 'Toggle Checkbox'
})
