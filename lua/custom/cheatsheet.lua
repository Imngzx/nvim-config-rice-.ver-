local M = {}

-- =========================================================
-- ⚡ 1. 局部化 C-API (极致避免全局查表开销)
-- =========================================================
local api = vim.api
local fn = vim.fn
local math_floor = math.floor
local table_concat = table.concat
local string_rep = string.rep
local strdisplaywidth = api.nvim_strwidth
local strcharpart = fn.strcharpart

local nvim_buf_set_lines = api.nvim_buf_set_lines
local nvim_buf_set_extmark = api.nvim_buf_set_extmark
local nvim_get_keymap = api.nvim_get_keymap

local ns = api.nvim_create_namespace('VibeCheatsheet')

-- =========================================================
-- 🎮 2. 状态机与缓存池 (Zero-Allocation 思想)
-- =========================================================
local active_win = nil

---@type string[]|nil
local cache_lines = nil

-- SoA (Struct of Arrays) 缓存 Extmarks，避免生成海量临时 Table 触发 GC
local cache_em_row, cache_em_col, cache_em_end, cache_em_hl = {}, {}, {}, {}
local cache_em_count = 0

-- 监听终端尺寸变化，自动让缓存失效
api.nvim_create_autocmd('VimResized', {
  group = api.nvim_create_augroup('VibeCheatsheetResize', { clear = true }),
  callback = function() cache_lines = nil end,
})

-- =========================================================
-- ⚙️ 3. 数据层：分组规则与快速格式化
-- =========================================================
local group_rules = {
  { p = ' a', n = ' AI / CodeCompanion' },
  { p = ' b', n = '󰓩 Buffer / Workspace' },
  { p = ' c', n = ' Code / LSP' },
  { p = ' d', n = ' Debug (DAP)' },
  { p = ' f', n = '󰈞 Find / Search (Snacks)' },
  { p = ' g', n = '󰊢 Git / Neogit' },
  { p = ' p', n = '󰏖 Panel / Tools' },
  { p = ' r', n = ' Code Runner' },
  { p = ' s', n = ' Search History / Meta' },
  { p = ' t', n = ' Translate' },
  { p = ' u', n = '󰙵 UI & Toggles' },
  { p = ' z', n = ' Zettelkasten' },
}

local function format_lhs(lhs)
  return lhs:gsub(' ', '<Space>'):gsub('<lt>', '<')
end

-- =========================================================
-- 🚀 4. 排版与编译引擎 (只在缓存失效时执行)
-- =========================================================
local function build_data()
  if cache_lines then return end

  local all_maps = nvim_get_keymap('n')
  local groups = {}
  local other_group = { name = ' General / Others', keys = {}, count = 0 }

  for i = 1, #group_rules do
    groups[group_rules[i].p] = { name = group_rules[i].n, keys = {}, count = 0 }
  end

  -- 1. 过滤并分类映射 (只拿带 Desc 且以 Space 开头的核心键)
  for i = 1, #all_maps do
    local map = all_maps[i]
    local desc, lhs = map.desc, map.lhs
    if desc and desc ~= '' and lhs ~= '' then
      local matched = false
      for j = 1, #group_rules do
        local prefix = group_rules[j].p
        if lhs:sub(1, #prefix) == prefix then
          local g = groups[prefix]
          g.count = g.count + 1
          g.keys[g.count] = map
          matched = true
          break
        end
      end
      if not matched and lhs:byte(1) == 32 then -- 32 是空格 (Space leader)
        other_group.count = other_group.count + 1
        other_group.keys[other_group.count] = map
      end
    end
  end

  -- 按字母顺序排序
  local function sort_fn(a, b) return a.lhs < b.lhs end
  for i = 1, #group_rules do
    local g = groups[group_rules[i].p]
    if g.count > 0 then table.sort(g.keys, sort_fn) end
  end
  if other_group.count > 0 then table.sort(other_group.keys, sort_fn) end

  -- 2. 瀑布流列计算
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
    -- 找最短的列
    local shortest_col, min_lines = 1, 99999
    for i = 1, columns_count do
      if cols_count[i] < min_lines then
        min_lines = cols_count[i]
        shortest_col = i
      end
    end

    add_to_col(shortest_col, { is_title = true, text = g.name })
    for i = 1, g.count do
      local k = g.keys[i]
      add_to_col(shortest_col, { is_title = false, lhs = format_lhs(k.lhs), desc = k.desc })
    end
    add_to_col(shortest_col, { is_empty = true })
  end

  for i = 1, #group_rules do append_group(groups[group_rules[i].p]) end
  append_group(other_group)

  -- 3. 压平为行文本，并生成 SoA 格式的 Extmark 数据 (String Builder 模式)
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
        cache_em_hl[em_idx] = 'Title'

        local pad = col_width - strdisplaywidth(cell_str)
        if pad > 0 then cell_str = cell_str .. string_rep(' ', pad) end
      else
        local lhs_pad = 17
        local lhs_fmt = '  %-' .. lhs_pad .. 's'
        local lhs_str = string.format(lhs_fmt, item.lhs)

        em_idx = em_idx + 1
        cache_em_row[em_idx] = row - 1
        cache_em_col[em_idx] = current_byte + 2
        cache_em_end[em_idx] = current_byte + 2 + #item.lhs
        cache_em_hl[em_idx] = 'Keyword'

        local desc_str = item.desc
        local desc_w = strdisplaywidth(desc_str)
        local max_desc_w = col_width - lhs_pad - 4

        -- 安全处理包含中文字符的截断
        if desc_w > max_desc_w then
          desc_str = strcharpart(desc_str, 0, max_desc_w - 3) .. '...'
        end

        em_idx = em_idx + 1
        cache_em_row[em_idx] = row - 1
        cache_em_col[em_idx] = current_byte + #lhs_str
        cache_em_end[em_idx] = current_byte + #lhs_str + #desc_str
        cache_em_hl[em_idx] = 'Comment'

        cell_str = lhs_str .. desc_str
        local pad = col_width - strdisplaywidth(cell_str)
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

-- =========================================================
-- 🪟 5. 视图控制 (使用 Snacks.win 完美融入)
-- =========================================================
function M.toggle()
  if active_win and active_win:valid() then
    active_win:close()
    active_win = nil
    return
  end

  build_data()

  active_win = require('snacks').win({
    position = 'float',
    width = 0.8,
    height = 0.8,
    border = 'rounded',
    backdrop = 60,
    title = ' 🚀 Vibe Cheatsheet ',
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

  -- 🚀 [修复点]: 增加 nil 检查进行类型收窄 (Type Narrowing)
  -- 这样 lua_ls 就明确知道 buf 是 integer，cache_lines 是 string[]
  if not buf or not cache_lines then return end

  -- 1. 注入文本 (一次性)
  nvim_buf_set_lines(buf, 0, -1, false, cache_lines)

  -- 2. 批量注入高亮 (极限性能：重复使用同一个 opts table 避免产生碎片垃圾)
  local ext_opts = { end_row = 0, end_col = 0, hl_group = '' }
  for i = 1, cache_em_count do
    ext_opts.end_row = cache_em_row[i]
    ext_opts.end_col = cache_em_end[i]
    ext_opts.hl_group = cache_em_hl[i]
    -- 此时的 buf 已经通过了上面的检查，LSP 不会再报错了
    nvim_buf_set_extmark(buf, ns, cache_em_row[i], cache_em_col[i], ext_opts)
  end

  -- 3. 锁定 Buffer
  vim.bo[buf].modifiable = false
end

return M
