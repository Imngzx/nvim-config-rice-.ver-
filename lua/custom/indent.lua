-- https://github.com/nvimdev/indentmini.nvim/blob/main/lua/indentmini/init.lua
local M = {}
local api = vim.api
local ns = api.nvim_create_namespace("indent_guides")
local config = {
  indent_width = vim.opt.shiftwidth:get(),
  highlight = "LineIndent",
  char = "│",
  only_current = false,
  exclude = { "dashboard", "lazy", "help", "nofile", "terminal", "prompt", "qf" },
}
local context = {
  snapshot = {},
  currow = 0,
  curcol = 0,
  range_srow = nil,
  range_erow = nil,
}
-- Tree-sitter get syntax blocks
local function get_blocks(buf)
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok then return {} end
  local tree = parser:parse()[1]
  if not tree then return {} end
  local root = tree:root()
  local blocks = {}
  local targets = {
    table_constructor = true,
    block = true,
    arguments = true,
    function_call = true,
    if_statement = true,
    while_statement = true,
    for_numeric = true,
    for_generic = true,
    repeat_statement = true,
  }
  local function walk(n)
    if targets[n:type()] then
      local s, _, e, _ = n:range()
      if e > s then
        blocks[#blocks + 1] = { s, e }
      end
    end
    for i = 0, n:child_count() - 1 do
      walk(n:child(i))
    end
  end
  walk(root)
  return blocks
end

-- Calculate syntax level based on blocks
local function syntax_level(blocks, line)
  local lv = 0
  for i = 1, #blocks do
    local s, e = blocks[i][1], blocks[i][2]
    if line >= s and line < e then
      lv = lv + 1
    end
  end
  return lv
end
-- Calculate indent level
local function indent_level(text, width)
  local s = text:match("^%s*")
  return math.floor(#s / width)
end

-- Pack and unpack line info
local function pack_snapshot(is_empty, indent, indent_cols)
  return bit.bor(
    bit.lshift(is_empty and 1 or 0, 15),
    bit.lshift(bit.band(indent, 0x3F), 9),
    bit.band(indent_cols, 0x1FF)
  )
end
local function unpack_snapshot(packed)
  return {
    is_empty = bit.band(bit.rshift(packed, 15), 1) == 1,
    indent = bit.band(bit.rshift(packed, 9), 0x3F),
    indent_cols = bit.band(packed, 0x1FF),
  }
end
-- Build line snapshot
local function make_snapshot(buf, lnum)
  local text = api.nvim_buf_get_lines(buf, lnum, lnum + 1, false)[1] or ""
  local is_empty = text:match("^%s*$") ~= nil
  local indent = is_empty and 0 or indent_level(text, config.indent_width)
  local indent_cols = #text:match("^%s*")
  local packed = pack_snapshot(is_empty, indent, indent_cols)
  context.snapshot[lnum] = packed
  return unpack_snapshot(packed)
end
-- Find line snapshot
local function find_in_snapshot(buf, lnum)
  local packed = context.snapshot[lnum]
  if not packed then
    return make_snapshot(buf, lnum)
  end
  return unpack_snapshot(packed)
end
-- Find current indent block range
local function find_current_range(buf)
  local sp = find_in_snapshot(buf, context.currow)
  local cur_indent = sp.indent
  context.range_srow = context.currow
  context.range_erow = context.currow
  -- Up
  for i = context.currow - 1, 0, -1 do
    local s = find_in_snapshot(buf, i)
    if not s.is_empty and s.indent < cur_indent then break end
    context.range_srow = i
  end
  -- Down
  local lines = api.nvim_buf_line_count(buf)
  for i = context.currow + 1, lines - 1 do
    local s = find_in_snapshot(buf, i)
    if not s.is_empty and s.indent < cur_indent then break end
    context.range_erow = i
  end
end

-- Render indent guides
local function render(buf)
  if not api.nvim_buf_is_valid(buf) then return end
  local lines = api.nvim_buf_line_count(buf)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  context.snapshot = {}

  local blocks = get_blocks(buf)
  local prev_lvl = 0
  local pos = api.nvim_win_get_cursor(0)
  context.currow = pos[1] - 1
  context.curcol = pos[2]
  find_current_range(buf)

  for l = 0, lines - 1 do
    local text = api.nvim_buf_get_lines(buf, l, l + 1, false)[1] or ""
    local syn = syntax_level(blocks, l)
    local lvl
    if text:match("^%s*$") then
      lvl = math.min(prev_lvl, syn)
    else
      lvl = math.min(indent_level(text, config.indent_width), syn)
      prev_lvl = lvl
    end

    for i = 1, lvl do
      local hl = (config.only_current and l >= context.range_srow and l <= context.range_erow and i == lvl)
          and "CursorColumn" or config.highlight
      api.nvim_buf_set_extmark(buf, ns, l, 0, {
        virt_text = { { config.char, hl } },
        virt_text_pos = "overlay",
        virt_text_win_col = (i - 1) * config.indent_width,
      })
    end
  end
end

function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})

  local hl = vim.api.nvim_get_hl(0, { name = config.highlight })
  if not hl.fg then
    vim.api.nvim_set_hl(0, config.highlight, { fg = "#424A51" })
  end

  vim.api.nvim_create_autocmd({
    "BufEnter",
    "TextChanged", "TextChangedI",
    "CursorMoved",
  }, {
    callback = function(a)
      vim.schedule(function() render(a.buf) end)
    end
  })
end

return M
