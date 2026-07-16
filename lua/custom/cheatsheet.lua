local M = {}

local api = vim.api
local fn = vim.fn

local math_floor = math.floor
local table_concat = table.concat
local table_sort = table.sort
local string_rep = string.rep
local string_sub = string.sub
local string_format = string.format
local string_byte = string.byte

local nvim_buf_set_lines = api.nvim_buf_set_lines
local nvim_buf_set_extmark = api.nvim_buf_set_extmark
local nvim_get_keymap = api.nvim_get_keymap
local nvim_buf_get_keymap = api.nvim_buf_get_keymap
local nvim_get_current_buf = api.nvim_get_current_buf
local nvim_strwidth = api.nvim_strwidth
local strcharpart = fn.strcharpart

local ns = api.nvim_create_namespace('VibeCheatsheet')

local active_win = nil

---@type string[]|nil
local cache_lines = nil
local last_bufnr = -1

local cache_em_row, cache_em_col, cache_em_end, cache_em_hl = {}, {}, {}, {}
local cache_em_count = 0

api.nvim_create_autocmd('VimResized', {
  group = api.nvim_create_augroup('VibeCheatsheetResize', { clear = true }),
  callback = function() cache_lines = nil end,
})

local group_rules = {
  { p = ' a', n = ' AI / CodeCompanion', hl = 'Special' },
  { p = ' b', n = '󰓩 Buffer / Workspace', hl = 'String' },
  { p = ' c', n = ' Code / LSP', hl = 'Type' },
  { p = ' d', n = ' Debug (DAP)', hl = 'DiagnosticError' },
  { p = ' f', n = '󰈞 Find / Search', hl = 'DiagnosticInfo' },
  { p = ' g', n = '󰊢 Git / Neogit', hl = 'Constant' },
  { p = ' p', n = '󰏖 Panel / Tools', hl = 'Operator' },
  { p = ' r', n = ' Code Runner', hl = 'Macro' },
  { p = ' s', n = ' Search Meta', hl = 'Keyword' },
  { p = ' t', n = ' Translate', hl = 'Function' },
  { p = ' u', n = '󰙵 UI & Toggles', hl = 'DiagnosticHint' },
  { p = ' z', n = ' Zettelkasten', hl = 'Label' },
}

local function format_lhs(lhs)
  return lhs:gsub(' ', '<Space>'):gsub('<lt>', '<')
end

local function build_data()
  if cache_lines then return end

  local groups = {}
  local other_group = { name = ' General / Others', hl = 'Title', keys = {}, count = 0 }

  for i = 1, #group_rules do
    groups[group_rules[i].p] = { name = group_rules[i].n, hl = group_rules[i].hl, keys = {}, count = 0 }
  end

  local maps_dict = {}
  local global_maps = nvim_get_keymap('n')
  for i = 1, #global_maps do
    local m = global_maps[i]
    if m.desc and m.desc ~= '' and m.lhs ~= '' then
      maps_dict[m.lhs] = m
    end
  end

  local buf_maps = nvim_buf_get_keymap(0, 'n')
  for i = 1, #buf_maps do
    local m = buf_maps[i]
    if m.desc and m.desc ~= '' and m.lhs ~= '' then
      maps_dict[m.lhs] = m
    end
  end

  local maps_list = {}
  local maps_count = 0
  for _, m in pairs(maps_dict) do
    maps_count = maps_count + 1
    maps_list[maps_count] = m
  end

  for i = 1, maps_count do
    local map = maps_list[i]
    local lhs = map.lhs
    local matched = false

    for j = 1, #group_rules do
      local prefix = group_rules[j].p
      if string_sub(lhs, 1, #prefix) == prefix then
        local g = groups[prefix]
        g.count = g.count + 1
        g.keys[g.count] = map
        matched = true
        break
      end
    end

    if not matched and string_byte(lhs, 1) == 32 then
      other_group.count = other_group.count + 1
      other_group.keys[other_group.count] = map
    end
  end

  local function sort_fn(a, b) return a.lhs < b.lhs end
  for i = 1, #group_rules do
    local g = groups[group_rules[i].p]
    if g.count > 0 then table_sort(g.keys, sort_fn) end
  end
  if other_group.count > 0 then table_sort(other_group.keys, sort_fn) end

  local col_width = 46
  local columns_count = math_floor((vim.o.columns * 0.8) / col_width)
  if columns_count < 1 then columns_count = 1 end

  local cols_data, cols_count = {}, {}
  for i = 1, columns_count do
    cols_data[i] = {}
    cols_count[i] = 0
  end

  local function add_to_col(col_idx, item)
    local c = cols_count[col_idx] + 1
    cols_count[col_idx] = c
    cols_data[col_idx][c] = item
  end

  local function append_group(g)
    if g.count == 0 then return end
    local shortest_col, min_lines = 1, 99999
    for i = 1, columns_count do
      if cols_count[i] < min_lines then
        min_lines = cols_count[i]
        shortest_col = i
      end
    end

    add_to_col(shortest_col, { is_title = true, text = g.name, hl = g.hl })
    for i = 1, g.count do
      local k = g.keys[i]
      add_to_col(shortest_col, { is_title = false, lhs = format_lhs(k.lhs), desc = k.desc })
    end
    add_to_col(shortest_col, { is_empty = true })
  end

  for i = 1, #group_rules do append_group(groups[group_rules[i].p]) end
  append_group(other_group)

  local max_rows = 0
  for i = 1, columns_count do
    if cols_count[i] > max_rows then max_rows = cols_count[i] end
  end

  local lines = {}
  local em_idx = 0

  for row = 1, max_rows do
    local line_parts = {}
    local current_byte = 0

    for col = 1, columns_count do
      local item = cols_data[col][row]
      local cell_str = ''

      if not item or item.is_empty then
        cell_str = string_rep(' ', col_width)
      elseif item.is_title then
        cell_str = ' ' .. item.text
        em_idx = em_idx + 1
        cache_em_row[em_idx] = row - 1
        cache_em_col[em_idx] = current_byte
        cache_em_end[em_idx] = current_byte + #cell_str
        cache_em_hl[em_idx] = item.hl

        local pad = col_width - nvim_strwidth(cell_str)
        if pad > 0 then cell_str = cell_str .. string_rep(' ', pad) end
      else
        local lhs_pad = 17
        local lhs_fmt = '  %-' .. lhs_pad .. 's'
        local lhs_str = string_format(lhs_fmt, item.lhs)

        em_idx = em_idx + 1
        cache_em_row[em_idx] = row - 1
        cache_em_col[em_idx] = current_byte + 2
        cache_em_end[em_idx] = current_byte + 2 + #item.lhs
        cache_em_hl[em_idx] = 'Keyword'

        local desc_str = item.desc
        local desc_w = nvim_strwidth(desc_str)
        local max_desc_w = col_width - lhs_pad - 4

        if desc_w > max_desc_w then
          desc_str = strcharpart(desc_str, 0, max_desc_w - 3) .. '...'
        end

        em_idx = em_idx + 1
        cache_em_row[em_idx] = row - 1
        cache_em_col[em_idx] = current_byte + #lhs_str
        cache_em_end[em_idx] = current_byte + #lhs_str + #desc_str
        cache_em_hl[em_idx] = 'Comment'

        cell_str = lhs_str .. desc_str
        local pad = col_width - nvim_strwidth(cell_str)
        if pad > 0 then cell_str = cell_str .. string_rep(' ', pad) end
      end

      line_parts[col] = cell_str
      current_byte = current_byte + #cell_str
    end
    lines[row] = table_concat(line_parts)
  end

  cache_lines = lines
  cache_em_count = em_idx
end

function M.toggle()
  if active_win and active_win:valid() then
    active_win:close()
    active_win = nil
    return
  end

  local current_buf = nvim_get_current_buf()
  if last_bufnr ~= current_buf then
    cache_lines = nil
    last_bufnr = current_buf
  end

  build_data()

  active_win = require('snacks').win({
    position = 'float',
    width = 0.8,
    height = 0.8,
    border = 'rounded',
    backdrop = 60,
    title = ' 🚀 Cheatsheet ',
    title_pos = 'center',
    zindex = 45,
    enter = true,
    bo = {
      modifiable = true,
      buftype = 'nofile',
      filetype = 'nvcheatsheet',
    },
    wo = {
      winhighlight = 'NormalFloat:Normal,FloatBorder:FloatBorder',
      spell = false,
      wrap = false,
      signcolumn = 'no',
      statuscolumn = ' ',
    },
    keys = {
      q = 'close',
      ['<Esc>'] = 'close',
    }
  })

  local buf = active_win.buf
  if not buf or not cache_lines then return end

  nvim_buf_set_lines(buf, 0, -1, false, cache_lines)

  local ext_opts = { end_row = 0, end_col = 0, hl_group = '' }
  for i = 1, cache_em_count do
    ext_opts.end_row = cache_em_row[i]
    ext_opts.end_col = cache_em_end[i]
    ext_opts.hl_group = cache_em_hl[i]
    nvim_buf_set_extmark(buf, ns, cache_em_row[i], cache_em_col[i], ext_opts)
  end

  vim.bo[buf].modifiable = false
end

return M
