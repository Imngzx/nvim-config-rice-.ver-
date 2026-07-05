local api = vim.api
local pcall = pcall
local string_format = string.format
local string_gmatch = string.gmatch
local table_insert = table.insert
local table_concat = table.concat

local nvim_win_get_cursor = api.nvim_win_get_cursor
local nvim_win_get_buf = api.nvim_win_get_buf
local nvim_buf_get_name = api.nvim_buf_get_name
local nvim_get_current_win = api.nvim_get_current_win
local nvim_buf_get_changedtick = api.nvim_buf_get_changedtick
local nvim_get_option_value = api.nvim_get_option_value

local fs_basename = vim.fs.basename
local fs_dirname = vim.fs.dirname
local fs_normalize = vim.fs.normalize
local env_home = vim.env.HOME or vim.env.USERPROFILE
local pesc_home = env_home and '^' .. vim.pesc(fs_normalize(env_home)) or nil
local _ts_pos = { 0, 0 }
local _ts_args = { bufnr = 0, pos = _ts_pos, ignore_injections = false }

local str_byteindex = vim.str_byteindex
local function truncate_utf8(str, max_chars)
  if #str <= max_chars then return str end
  local ok, byte_idx = pcall(str_byteindex, str, max_chars)
  if ok and byte_idx and byte_idx < #str then
    return str:sub(1, byte_idx) .. '…'
  end
  return str
end

local function escape_stl(str)
  return str:gsub('%%', '%%%%')
end

local ts_get_node_cache = nil
local ts_get_node_text_cache = nil

local function get_ts_node(...)
  if not ts_get_node_cache then ts_get_node_cache = vim.treesitter.get_node end
  return ts_get_node_cache(...)
end

local function get_ts_text(...)
  if not ts_get_node_text_cache then ts_get_node_text_cache = vim.treesitter.get_node_text end
  return ts_get_node_text_cache(...)
end

local mini_icons_cache = nil
local function get_mini_icons()
  if mini_icons_cache == nil then
    local ok, m = pcall(require, 'mini.icons')
    mini_icons_cache = ok and m or false
  end
  return mini_icons_cache
end

local BUF_ZERO = { buf = 0 }
local FIELDS_TO_TRY = { 'name', 'key', 'property', 'declarator', 'item' }
local HEADING_ICONS = { 'H1', 'H2', 'H3', 'H4', 'H5', 'H6' }

local ts_icons = {
  ['class'] = { icon = '󰠱', hl = 'Type' },
  ['function'] = { icon = '󰊕', hl = 'Function' },
  ['method'] = { icon = '󰆧', hl = 'Method' },
  ['struct'] = { icon = '󰙅', hl = 'Structure' },
  ['enum'] = { icon = '󰅟', hl = 'Type' },
  ['interface'] = { icon = '', hl = 'Type' },
  ['module'] = { icon = '󰏗', hl = 'Include' },
  ['namespace'] = { icon = '󰅪', hl = 'Include' },
  ['object'] = { icon = '󰅪', hl = 'Type' },
  ['array'] = { icon = '󰅪', hl = 'Type' },
  ['field'] = { icon = '󰜢', hl = 'Identifier' },
  ['tag'] = { icon = '󰀓', hl = 'Tag' },
  ['heading'] = { icon = '', hl = 'Title' },
  ['statement'] = { icon = '󱞩', hl = 'Conditional' },
  ['default'] = { icon = '󰘧', hl = 'String' },
}

local win_cache = {}
local file_cache = {}

local aug = api.nvim_create_augroup('HeirlineWinbarCache', { clear = true })
api.nvim_create_autocmd('WinClosed', {
  group = aug,
  callback = function(args)
    local win_id = tonumber(args.match)
    if win_id then win_cache[win_id] = nil end
  end
})
api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
  group = aug,
  callback = function(args) file_cache[args.buf] = nil end
})

local scope_memo = {}

local function identify_scope(type_str)
  local cached = scope_memo[type_str]
  if cached ~= nil then return cached or nil end

  local res = nil
  if type_str:find('func', 1, true) then
    res = 'function'
  elseif type_str:find('method', 1, true) then
    res = 'method'
  elseif type_str:find('class', 1, true) then
    res = 'class'
  elseif type_str:find('struct', 1, true) then
    res = 'struct'
  elseif type_str:find('enum', 1, true) then
    res = 'enum'
  elseif type_str:find('interface', 1, true) or type_str:find('trait', 1, true) then
    res = 'interface'
  elseif type_str:find('module', 1, true) then
    res = 'module'
  elseif type_str:find('namespace', 1, true) then
    res = 'namespace'
  elseif type_str == 'element' or type_str == 'jsx_element' then
    res = 'tag'
  elseif type_str:find('table', 1, true) or type_str:find('dict', 1, true) or type_str:find('object', 1, true) then
    res = 'object'
  elseif type_str:find('array', 1, true) or type_str:find('list', 1, true) then
    res = 'array'
  elseif type_str:find('if', 1, true) or type_str:find('for', 1, true) or type_str:find('while', 1, true) or type_str:find('match', 1, true) then
    res = 'statement'
  elseif type_str:find('pair', 1, true) or type_str:find('property', 1, true) or type_str:find('field', 1, true) then
    res = 'field'
  elseif type_str == 'section' or type_str:find('heading', 1, true) then
    res = 'heading'
  end

  scope_memo[type_str] = res or false
  return res
end

local function safe_get_text(node, bufnr)
  local ok, text = pcall(get_ts_text, node, bufnr)
  return ok and text or nil
end

local function get_node_name(node, bufnr)
  local type_str = node:type()

  if type_str == 'section' then
    for i = 0, node:named_child_count() - 1 do
      local child = node:named_child(i)
      if child:type():find('heading', 1, true) then
        node, type_str = child, child:type()
        break
      end
    end
  end

  if type_str:find('heading', 1, true) then
    local level, full_text = 1, safe_get_text(node, bufnr)
    if full_text then
      local hashes = full_text:match('^(#+)')
      if hashes then level = #hashes end
    end
    local dynamic_icon = HEADING_ICONS[level] or ('H' .. tostring(level))
    for i = 0, node:named_child_count() - 1 do
      local child = node:named_child(i)
      if child:type() == 'inline' then
        local text = safe_get_text(child, bufnr)
        if text then return (text:gsub('%s+', ' ')), dynamic_icon end
      end
    end
    if full_text then return (full_text:gsub('^#+%s*', ''):gsub('%s+', ' ')), dynamic_icon end
  end

  if type_str == 'element' or type_str == 'jsx_element' then
    local name_nodes = node:field('name')
    if name_nodes and name_nodes[1] then
      local text = safe_get_text(name_nodes[1], bufnr)
      if text then return (text:gsub('%s+', ' ')) end
    end
    local start_node = node:named_child(0)
    if start_node then
      local stype = start_node:type()
      if stype:find('tag', 1, true) or stype:find('opening', 1, true) then
        local name_node = start_node:named_child(0)
        if name_node then
          local text = safe_get_text(name_node, bufnr)
          if text then return (text:gsub('%s+', ' ')) end
        end
      end
    end
  end

  for i = 1, #FIELDS_TO_TRY do
    local field_nodes = node:field(FIELDS_TO_TRY[i])
    if field_nodes and field_nodes[1] then
      local text = safe_get_text(field_nodes[1], bufnr)
      if text then
        text = text:gsub('%s+', ' ')
        text = truncate_utf8(text, 25)
        return (text:gsub('^["\']', ''):gsub('["\']$', ''))
      end
    end
  end

  if type_str:find('pair', 1, true) or type_str:find('key_value', 1, true) then
    local first_child = node:named_child(0)
    if first_child then
      local text = safe_get_text(first_child, bufnr)
      if text then return (text:gsub('^["\']', ''):gsub('["\']$', ''):gsub('%s+', ' ')) end
    end
  end

  local start_row, start_col = node:range()
  local ok, lines = pcall(api.nvim_buf_get_lines, bufnr, start_row, start_row + 1, false)
  if ok and lines and lines[1] then
    local text = lines[1]:sub(start_col + 1)
    text = text:gsub('^%s+', ''):gsub('%s*[{]*%s*$', '')
    text = truncate_utf8(text, 35)
    if text ~= '' then return text end
  end

  return nil
end

local FilePath = {
  init = function(self)
    local win_id = nvim_get_current_win()
    local bufnr = nvim_win_get_buf(win_id)
    local filename = nvim_buf_get_name(bufnr)

    if filename == '' then
      self.path_full, self.path_short, self.path_tail = '[No Name]', '[No Name]', '[No Name]'
      return
    end

    local cache = file_cache[bufnr]
    if cache and cache.filename == filename then
      self.path_full, self.path_short, self.path_tail = cache.path_full, cache.path_short,
        cache.path_tail
      return
    end

    local rel_path = fs_normalize(filename)
    if pesc_home then rel_path = rel_path:gsub(pesc_home, '~') end

    local dir = fs_dirname(rel_path) or ''
    local tail = fs_basename(rel_path) or ''

    local mini_icons = get_mini_icons()
    local dir_icon, dir_hl = '󰉋', 'Directory'
    if mini_icons then dir_icon, dir_hl = mini_icons.get('directory', 'folder') end

    local full_rendered, short_rendered = '', ''

    if dir and dir ~= '.' and dir ~= '' then
      dir = dir:gsub('\\', '/')
      for segment in string_gmatch(dir, '[^/]+') do
        local short_segment = segment:sub(1, 1)
        segment = escape_stl(segment)
        short_segment = escape_stl(short_segment)
        full_rendered = full_rendered ..
          string_format('%%#%s#%s %%#WinBar#%s%%#Comment# ', dir_hl, dir_icon, segment)
        short_rendered = short_rendered ..
          string_format('%%#%s#%s %%#WinBar#%s%%#Comment# ', dir_hl, dir_icon, short_segment)
      end
    end

    local file_icon, file_hl = '󰈔', 'Comment'
    if mini_icons then file_icon, file_hl = mini_icons.get('file', filename) end

    tail = escape_stl(tail)
    local tail_part = string_format('%%#%s#%s %%#WinBar#%s', file_hl, file_icon, tail)

    self.path_full = full_rendered .. tail_part
    self.path_short = short_rendered .. tail_part
    self.path_tail = tail_part

    file_cache[bufnr] = {
      filename = filename,
      path_full = self.path_full,
      path_short = self.path_short,
      path_tail = self.path_tail
    }
  end,
  flexible = 1,
  { provider = function(self) return self.path_full end },
  { provider = function(self) return self.path_short end },
  { provider = function(self) return self.path_tail end },
}

local Breadcrumbs = {
  init = function(self)
    local win_id = nvim_get_current_win()
    local bufnr = nvim_win_get_buf(win_id)
    local cursor = nvim_win_get_cursor(win_id)
    local row, col = cursor[1] - 1, cursor[2]
    local tick = nvim_buf_get_changedtick(bufnr)
    _ts_pos[1] = row
    _ts_pos[2] = col
    _ts_args.bufnr = bufnr

    local ok, node = pcall(get_ts_node, _ts_args)
    if not ok or not node then
      self.rendered_string = ''
      return
    end

    ---@type TSNode?
    local scope_node = node
    local start_scope = nil
    while scope_node do
      start_scope = identify_scope(scope_node:type())
      if start_scope then break end
      scope_node = scope_node:parent()
    end

    local scope_id = scope_node and scope_node:id() or -1

    local cache = win_cache[win_id]
    if cache and cache.bufnr == bufnr and cache.tick == tick and cache.scope_id == scope_id then
      self.rendered_string = cache.rendered_string
      return
    end

    local parts = {}
    local max_depth = 5
    local curr_depth = 0

    while scope_node and curr_depth < max_depth do
      local name, icon_override = get_node_name(scope_node, bufnr)
      if name then
        local icon_data = ts_icons[start_scope] or ts_icons['default']
        local final_icon = icon_override or icon_data.icon

        name = truncate_utf8(name, 40)
        name = escape_stl(name)

        local part = string_format('%%#Comment# %%#%s#%s %%#WinBar#%s', icon_data.hl, final_icon,
          name)
        table_insert(parts, 1, part)
        curr_depth = curr_depth + 1
      end

      scope_node = scope_node:parent()
      while scope_node do
        start_scope = identify_scope(scope_node:type())
        if start_scope then break end
        scope_node = scope_node:parent()
      end
    end

    if curr_depth == max_depth and scope_node then
      table_insert(parts, 1, '%#Comment# ⋯ ')
    end

    local rendered = table_concat(parts)
    self.rendered_string = rendered

    win_cache[win_id] = { bufnr = bufnr, tick = tick, scope_id = scope_id, rendered_string = rendered }
  end,
  provider = function(self) return self.rendered_string end,
}

local TerminalWinBar = {
  condition = function()
    if vim.api.nvim_win_get_config(0).zindex then return false end
    return nvim_get_option_value('buftype', BUF_ZERO) == 'terminal'
  end,
  init = function(self)
    local name = nvim_buf_get_name(0)
    local norm_name = fs_normalize(name)
    if env_home then
      local term_prefix = 'term://' .. fs_normalize(env_home)
      norm_name = norm_name:gsub('^' .. vim.pesc(term_prefix), 'term://~')
    end
    self.term_name = escape_stl(norm_name)
  end,
  { provider = ' ' },
  {
    provider = function(self)
      return string.format('%%#Macro#  %%#WinBar#%s', self.term_name)
    end
  }
}

local NormalWinBar = {
  condition = function()
    if vim.api.nvim_win_get_config(0).zindex then return false end
    local bt = nvim_get_option_value('buftype', BUF_ZERO)
    if bt == 'nofile' or bt == 'prompt' or bt == 'help' then return false end
    local ft = nvim_get_option_value('filetype', BUF_ZERO)
    if ft == 'snacks_dashboard' or ft:match('^snacks_picker') then return false end
    return true
  end,

  { provider = ' ' },
  FilePath,
  { provider = '%<' },
  Breadcrumbs,
}

local WinBar = {
  fallthrough = false, -- 只匹配第一个条件为 true 的子块
  TerminalWinBar,
  NormalWinBar,
}

return WinBar
