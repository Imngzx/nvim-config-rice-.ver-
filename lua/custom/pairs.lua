-- https://github.com/nvim-mini/mini.pairs/blob/main/lua/mini/pairs.lua

-- Config
-- require('<this_file>').setup({
--   -- Mode that setup
--   modes = {
--     insert = true,
--     command = false,
--     terminal = false
--   },
--   -- Mappings
--   mappings = {
--     ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
--     ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
--     ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },
--     [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
--     [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
--     ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },
--     -- Quotation marks expand by default when absent <CR>
--     ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\]. ', register = { cr = false } },
--     ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
--     ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },
--     -- Disable mapping
--     -- ['`'] = false,
--   },
-- })

local MiniPairs = {}
local H = {}

--- Module setup
---@param config table|nil Module config
MiniPairs.setup = function(config)
  _G.MiniPairs = MiniPairs
  config = H.setup_config(config)
  H.apply_config(config)
  H.create_autocommands()
end

--- Default configuration
MiniPairs.config = {
  modes = { insert = true, command = false, terminal = false },
  mappings = {
    ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
    ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
    ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },
    [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
    [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
    ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },
    ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
    ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
    ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },
  },
}

--- Global mapping
MiniPairs.map = function(mode, lhs, pair_info, opts)
  pair_info = H.validate_pair_info(pair_info)
  opts = vim.tbl_deep_extend('force', opts or {}, { expr = true, noremap = true })
  opts.desc = H.infer_mapping_description(pair_info)

  vim.api.nvim_set_keymap(mode, lhs, H.pair_info_to_map_rhs(pair_info), opts)
  H.register_pair(pair_info, mode, 'all')
  H.ensure_cr_bs(mode)
end

--- Buffer mapping
MiniPairs.map_buf = function(buffer, mode, lhs, pair_info, opts)
  pair_info = H.validate_pair_info(pair_info)
  opts = vim.tbl_deep_extend('force', opts or {}, { expr = true, noremap = true })
  opts.desc = H.infer_mapping_description(pair_info)

  vim.api.nvim_buf_set_keymap(buffer, mode, lhs, H.pair_info_to_map_rhs(pair_info), opts)
  H.register_pair(pair_info, mode, buffer == 0 and vim.api.nvim_get_current_buf() or buffer)
  H.ensure_cr_bs(mode)
end

--- Process "open" symbols
MiniPairs.open = function(pair, neigh_pattern)
  if H.is_disabled() or not H.neigh_match(neigh_pattern) then
    return H.get_open_char(pair)
  end

  -- Temporarily redraw lazily for no cursor flicker due to `<Left>`
  H.with_temp_option('lazyredraw', true)

  return pair .. H.get_arrow_key('left')
end

--- Process "close" symbols
MiniPairs.close = function(pair, neigh_pattern)
  local close = H.get_close_char(pair)
  local move_right = not H.is_disabled() and H.neigh_match(neigh_pattern) and
    H.get_neigh('right') == close
  return move_right and H.get_arrow_key('right', true) or close
end

--- Process "closeopen" symbols
MiniPairs.closeopen = function(pair, neigh_pattern)
  local move_right = not H.is_disabled() and H.get_neigh('right') == H.get_close_char(pair)
  return move_right and H.get_arrow_key('right', true) or MiniPairs.open(pair, neigh_pattern)
end

--- Process <BS>
MiniPairs.bs = function(key)
  local res, neigh = key or H.keys.bs, H.get_neigh('whole')
  local do_extra = not H.is_disabled() and H.is_pair_registered(neigh, vim.fn.mode(), 'bs')
  return do_extra and (res .. H.keys.del) or res
end

--- Process <CR>
MiniPairs.cr = function(key)
  local res = key or H.keys.cr

  local neigh = H.get_neigh('whole')
  if H.is_disabled() or not H.is_pair_registered(neigh, vim.fn.mode(), 'cr') then return res end

  -- Temporarily ignore mode change events
  H.with_temp_option('eventignore', 'InsertLeave,InsertLeavePre,InsertEnter,TextChanged,ModeChanged')

  -- Temporarily redraw lazily for no cursor flicker
  H.with_temp_option('lazyredraw', true)

  return res .. H.keys.above
end

-- Helper data
H.default_config = vim.deepcopy(MiniPairs.config)
H.default_pair_info = { neigh_pattern = '.. ', register = { bs = true, cr = true } }
H.registered_pairs = {
  i = { all = { bs = {}, cr = {} } },
  c = { all = { bs = {}, cr = {} } },
  t = { all = { bs = {}, cr = {} } },
}
H.options_cache = {}

local function escape(s)
  return vim.api.nvim_replace_termcodes(s, true, true, true)
end

H.keys = {
  above = escape('<C-o>O'),
  bs = escape('<BS>'),
  cr = escape('<CR>'),
  del = escape('<Del>'),
  ctrl_y = escape('<C-y>'),
  left = escape('<Left>'),
  right = escape('<Right>'),
  left_undo = escape('<C-g>U<Left>'),
  right_undo = escape('<C-g>U<Right>'),
}

-- Helper functions
H.setup_config = function(config)
  return vim.tbl_deep_extend('force', vim.deepcopy(H.default_config), config or {})
end

H.apply_config = function(config)
  MiniPairs.config = config

  local mode_ids = { insert = 'i', command = 'c', terminal = 't' }
  local mode_array = {}
  for name, to_set in pairs(config.modes) do
    if to_set then table.insert(mode_array, mode_ids[name]) end
  end

  local map_conditionally = function(mode, key, pair_info)
    if pair_info == false then return end
    MiniPairs.map(mode, key, pair_info)
  end

  for _, mode in pairs(mode_array) do
    for key, pair_info in pairs(config.mappings) do
      map_conditionally(mode, key, pair_info)
    end
  end
end

H.create_autocommands = function()
  local gr = vim.api.nvim_create_augroup('MiniPairs', {})
  vim.api.nvim_create_autocmd('FileType', {
    group = gr,
    pattern = { 'TelescopePrompt', 'fzf' },
    callback = function() vim.b.minipairs_disable = true end,
    desc = 'Disable locally'
  })
end

H.is_disabled = function()
  return vim.g.minipairs_disable == true or vim.b.minipairs_disable == true
end

H.register_pair = function(pair_info, mode, buffer)
  H.registered_pairs[mode] = H.registered_pairs[mode] or { all = { bs = {}, cr = {} } }
  local mode_pairs = H.registered_pairs[mode]

  local buf_pairs = mode_pairs[buffer] or { bs = {}, cr = {} }
  mode_pairs[buffer] = buf_pairs

  local register, pair = pair_info.register, pair_info.pair
  buf_pairs.bs[pair] = register.bs == true and true or nil
  buf_pairs.cr[pair] = register.cr == true and true or nil
end

H.is_pair_registered = function(pair, mode, key)
  local mode_pairs = H.registered_pairs[mode]
  if not mode_pairs then return false end

  if mode_pairs['all'][key][pair] then return true end

  local buf_pairs = mode_pairs[vim.api.nvim_get_current_buf()]
  if not buf_pairs then return false end

  return buf_pairs[key][pair] == true
end

H.ensure_cr_bs = function(mode)
  local has_any_cr_pair, has_any_bs_pair = false, false
  for _, pair_tbl in pairs(H.registered_pairs[mode]) do
    has_any_cr_pair = has_any_cr_pair or not vim.tbl_isempty(pair_tbl.cr)
    has_any_bs_pair = has_any_bs_pair or not vim.tbl_isempty(pair_tbl.bs)
  end

  if has_any_bs_pair and vim.fn.maparg('<BS>', mode) == '' then
    local opts = {
      silent = mode ~= 'c',
      expr = true,
      replace_keycodes = false,
      desc =
      'MiniPairs <BS>'
    }
    H.map(mode, '<BS>', 'v:lua.MiniPairs.bs()', opts)
  end
  if mode == 'i' and has_any_cr_pair and vim.fn.maparg('<CR>', mode) == '' then
    local opts = { expr = true, replace_keycodes = false, desc = 'MiniPairs <CR>' }
    H.map(mode, '<CR>', 'v:lua.MiniPairs.cr()', opts)
  end
end

H.validate_pair_info = function(x)
  x = vim.tbl_deep_extend('force', vim.deepcopy(H.default_pair_info), x)
  return x
end

H.pair_info_to_map_rhs = function(x)
  return string.format('v:lua.MiniPairs.%s(%s, %s)', x.action, vim.inspect(x.pair),
    vim.inspect(x.neigh_pattern))
end

H.infer_mapping_description = function(x)
  local action_name = x.action:sub(1, 1):upper() .. x.action:sub(2)
  return string.format('%s action for %s pair', action_name, vim.inspect(x.pair))
end

H.get_neigh = function(neigh_type)
  local is_command_mode = vim.fn.mode() == 'c'
  local line = is_command_mode and vim.fn.getcmdline() or vim.api.nvim_get_current_line()
  line = '\r' .. line .. '\n'
  local start = is_command_mode and vim.fn.charidx(line, vim.fn.getcmdpos()) or vim.fn.charcol('.')
  start = start - 1

  return vim.fn.strcharpart(line, start + (neigh_type == 'right' and 1 or 0),
    neigh_type == 'whole' and 2 or 1)
end

H.neigh_match = function(pattern)
  return H.get_neigh('whole'):find(pattern or '') ~= nil
end

H.get_open_char = function(x) return vim.fn.strcharpart(x, 0, 1) end
H.get_close_char = function(x) return vim.fn.strcharpart(x, 1, 1) end

H.get_arrow_key = function(key, ensure_no_wildmenu)
  if vim.fn.mode() == 'i' then
    -- Take into account that `virtualedit=all` can go into inline virtual text
    H.with_temp_option('virtualedit', 'none')
    return key == 'right' and H.keys.right_undo or H.keys.left_undo
  end
  local prefix = ''
  -- In Command-line mode <Left> / <Right> act like <C-p> / <C-n> if wildmenu is shown
  if vim.fn.mode() == 'c' and ensure_no_wildmenu then
    prefix = vim.fn.wildmenumode() == 1 and H.keys.ctrl_y or ''
  end
  return prefix .. (key == 'right' and H.keys.right or H.keys.left)
end

H.map = function(mode, lhs, rhs, opts)
  if lhs == '' then return end
  opts = vim.tbl_deep_extend('force', { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

H.with_temp_option = function(name, value)
  -- Cache option only once to not override it later with temporary set value
  if H.options_cache[name] == nil then H.options_cache[name] = vim.o[name] end
  vim.o[name] = value
  H.restore_option_later(name)
end

H.restore_option_later = vim.schedule_wrap(function(name)
  if H.options_cache[name] == nil then return end
  vim.o[name] = H.options_cache[name]
  H.options_cache[name] = nil
end)

return MiniPairs
