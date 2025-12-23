-- Simple Surround - A minimal surround implementation
-- Supports basic add, delete, and replace operations
-- https://github.com/nvim-mini/mini.surround/blob/main/lua/mini/surround.lua

local M = {}

-- Configuration
M.config = {
  -- Surround pairs mapping
  surrounds = {
    ['('] = { '(', ')' },
    [')'] = { '(', ')' },
    ['['] = { '[', ']' },
    [']'] = { '[', ']' },
    ['{'] = { '{', '}' },
    ['}'] = { '{', '}' },
    ['<'] = { '<', '>' },
    ['>'] = { '<', '>' },
    ['"'] = { '"', '"' },
    ["'"] = { "'", "'" },
    ['`'] = { '`', '`' },
    ['b'] = { '(', ')' }, -- alias for any bracket
  },
}

-- Add surrounding characters in visual mode
function M.add_visual()
  -- Get user input
  vim.api.nvim_echo({ { 'Surround with: ', 'Question' } }, false, {})
  local char = vim.fn.getcharstr()
  vim.api.nvim_echo({ { '' } }, false, {})

  -- Handle <Esc> or <C-c>
  if char == '\27' or char == '' then return end

  -- Get surround pair
  local surround = M.config.surrounds[char]
  if not surround then surround = { char, char } end

  local left, right = surround[1], surround[2]

  -- Get selection positions
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  local start_line = start_pos[2]
  local start_col = start_pos[3]
  local end_line = end_pos[2]
  local end_col = end_pos[3]

  -- Validate positions
  if start_line == 0 or end_line == 0 then return end

  -- Get lines
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  if #lines == 0 then return end

  if start_line == end_line then
    -- Single line case
    local line = lines[1]
    local before = line:sub(1, start_col - 1)
    local selection = line:sub(start_col, end_col)
    local after = line:sub(end_col + 1)

    local new_line = before .. left .. selection .. right .. after
    vim.api.nvim_buf_set_lines(0, start_line - 1, start_line, false, { new_line })

    -- Update cursor position
    vim.api.nvim_win_set_cursor(0, { start_line, start_col + #left - 1 })
  else
    -- Multi-line case
    local first_line = lines[1]
    local last_line = lines[#lines]

    -- Modify first line
    local new_first = first_line:sub(1, start_col - 1) .. left .. first_line:sub(start_col)
    lines[1] = new_first

    -- Modify last line
    local new_last = last_line:sub(1, end_col) .. right .. last_line:sub(end_col + 1)
    lines[#lines] = new_last

    -- Set all lines at once
    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)

    -- Update cursor position
    vim.api.nvim_win_set_cursor(0, { start_line, start_col + #left - 1 })
  end
end

-- Add surrounding with motion/textobject (for normal mode)
function M.add_normal()
  -- Store the operatorfunc
  local old_operatorfunc = vim.o.operatorfunc

  -- Set our custom operatorfunc
  _G._surround_add_operatorfunc = function()
    -- Get user input for surround character
    vim.api.nvim_echo({ { 'Surround with:  ', 'Question' } }, false, {})
    local char = vim.fn.getcharstr()
    vim.api.nvim_echo({ { '' } }, false, {})

    -- Handle <Esc> or <C-c>
    if char == '\27' or char == '' then
      vim.o.operatorfunc = old_operatorfunc
      return
    end

    -- Get surround pair
    local surround = M.config.surrounds[char]
    if not surround then surround = { char, char } end

    local left, right = surround[1], surround[2]

    -- Get motion marks
    local start_pos = vim.fn.getpos("'[")
    local end_pos = vim.fn.getpos("']")

    local start_line = start_pos[2]
    local start_col = start_pos[3]
    local end_line = end_pos[2]
    local end_col = end_pos[3]

    -- Get lines
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    if #lines == 0 then
      vim.o.operatorfunc = old_operatorfunc
      return
    end

    if start_line == end_line then
      -- Single line case
      local line = lines[1]
      local before = line:sub(1, start_col - 1)
      local selection = line:sub(start_col, end_col)
      local after = line:sub(end_col + 1)

      local new_line = before .. left .. selection .. right .. after
      vim.api.nvim_buf_set_lines(0, start_line - 1, start_line, false, { new_line })

      -- Update cursor position
      vim.api.nvim_win_set_cursor(0, { start_line, start_col + #left - 1 })
    else
      -- Multi-line case
      local first_line = lines[1]
      local last_line = lines[#lines]

      local new_first = first_line:sub(1, start_col - 1) .. left .. first_line:sub(start_col)
      lines[1] = new_first

      local new_last = last_line:sub(1, end_col) .. right .. last_line:sub(end_col + 1)
      lines[#lines] = new_last

      vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)

      vim.api.nvim_win_set_cursor(0, { start_line, start_col + #left - 1 })
    end

    -- Restore operatorfunc
    vim.o.operatorfunc = old_operatorfunc
  end

  vim.o.operatorfunc = 'v:lua._surround_add_operatorfunc'
  return 'g@'
end

-- Find surrounding characters around cursor
local function find_surround(char)
  -- Get all possible surround pairs for this char
  local pairs_to_try = {}

  if M.config.surrounds[char] then table.insert(pairs_to_try, M.config.surrounds[char]) end

  -- For brackets, try both open and close variants
  if char == '(' or char == ')' or char == 'b' then
    table.insert(pairs_to_try, { '(', ')' })
  elseif char == '[' or char == ']' then
    table.insert(pairs_to_try, { '[', ']' })
  elseif char == '{' or char == '}' then
    table.insert(pairs_to_try, { '{', '}' })
  elseif char == '<' or char == '>' then
    table.insert(pairs_to_try, { '<', '>' })
  else
    -- Default:  same character on both sides
    if #pairs_to_try == 0 then table.insert(pairs_to_try, { char, char }) end
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_num = cursor[1]
  local col = cursor[2] + 1 -- Convert to 1-based

  local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
  if not line then return nil end

  -- Try each possible pair
  for _, pair in ipairs(pairs_to_try) do
    local left, right = pair[1], pair[2]

    -- Search left from cursor
    local left_pos = nil
    for i = col, 1, -1 do
      if line:sub(i, i + #left - 1) == left then
        left_pos = i
        break
      end
    end

    -- Search right from cursor
    local right_pos = nil
    if left_pos then
      for i = col, #line do
        if line:sub(i, i + #right - 1) == right then
          right_pos = i
          break
        end
      end
    end

    -- Check if cursor is between left and right
    if left_pos and right_pos and left_pos < col and col <= right_pos then
      return {
        line = line_num,
        left_start = left_pos,
        left_end = left_pos + #left - 1,
        right_start = right_pos,
        right_end = right_pos + #right - 1,
      }
    end
  end

  return nil
end

-- Delete surrounding characters
function M.delete()
  -- Get user input
  vim.api.nvim_echo({ { 'Delete surround: ', 'Question' } }, false, {})
  local char = vim.fn.getcharstr()
  vim.api.nvim_echo({ { '' } }, false, {})

  -- Handle <Esc> or <C-c>
  if char == '\27' or char == '' then return end

  -- Find surround
  local pos = find_surround(char)
  if not pos then
    vim.notify('Surround not found', vim.log.levels.WARN)
    return
  end

  -- Delete surround
  local line = vim.api.nvim_buf_get_lines(0, pos.line - 1, pos.line, false)[1]

  -- Remove right part first
  local new_line = line:sub(1, pos.right_start - 1) .. line:sub(pos.right_end + 1)
  -- Then remove left part
  new_line = new_line:sub(1, pos.left_start - 1) .. new_line:sub(pos.left_end + 1)

  vim.api.nvim_buf_set_lines(0, pos.line - 1, pos.line, false, { new_line })

  -- Update cursor position
  vim.api.nvim_win_set_cursor(0, { pos.line, pos.left_start - 1 })
end

-- Replace surrounding characters
function M.replace()
  -- Get old surround
  vim.api.nvim_echo({ { 'Replace surround: ', 'Question' } }, false, {})
  local old_char = vim.fn.getcharstr()

  -- Handle <Esc> or <C-c>
  if old_char == '\27' or old_char == '' then
    vim.api.nvim_echo({ { '' } }, false, {})
    return
  end

  -- Get new surround
  vim.api.nvim_echo({ { 'With:  ', 'Question' } }, false, {})
  local new_char = vim.fn.getcharstr()
  vim.api.nvim_echo({ { '' } }, false, {})

  -- Handle <Esc> or <C-c>
  if new_char == '\27' or new_char == '' then return end

  -- Find old surround
  local pos = find_surround(old_char)
  if not pos then
    vim.notify('Surround not found', vim.log.levels.WARN)
    return
  end

  -- Get new surround pair
  local new_surround = M.config.surrounds[new_char]
  if not new_surround then new_surround = { new_char, new_char } end

  local new_left, new_right = new_surround[1], new_surround[2]

  -- Replace surround
  local line = vim.api.nvim_buf_get_lines(0, pos.line - 1, pos.line, false)[1]

  -- Replace right part first
  local new_line = line:sub(1, pos.right_start - 1) .. new_right .. line:sub(pos.right_end + 1)

  -- Then replace left part
  new_line = new_line:sub(1, pos.left_start - 1) .. new_left .. new_line:sub(pos.left_end + 1)

  vim.api.nvim_buf_set_lines(0, pos.line - 1, pos.line, false, { new_line })

  -- Update cursor position
  vim.api.nvim_win_set_cursor(0, { pos.line, pos.left_start + #new_left - 1 })
end

-- Setup keymaps
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  -- Visual mode: add surround
  vim.keymap.set('x', 'sa', function() return M.add_visual() end, {
    silent = true,
    desc = 'Add surround',
  })

  -- Normal mode: add surround with motion/textobject (supports saiw, sa2w, etc.)
  vim.keymap.set('n', 'sa', function() return M.add_normal() end, {
    expr = true,
    silent = true,
    desc = 'Add surround with motion',
  })

  -- Normal mode: delete surround
  vim.keymap.set('n', 'sd', function() M.delete() end, { desc = 'Delete surround' })

  -- Normal mode:  replace surround
  vim.keymap.set('n', 'sr', function() M.replace() end, { desc = 'Replace surround' })
end

return M
