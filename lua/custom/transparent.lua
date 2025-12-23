-- Transparent background
-- https://github.com/xiyaowong/transparent.nvim/blob/main/lua/transparent/init.lua

local M = {}
local api, fn = vim.api, vim.fn
local ORIGINAL_HL_CACHE = {}

-- Config Module
local config = {
  groups = {
    'Normal', 'NormalNC', 'SignColumn', 'EndOfBuffer',
    'LineNr', 'CursorLineNr', 'NonText',

    'Comment', 'Constant', 'Special', 'Identifier', 'Statement',
    'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
    'Conditional', 'Repeat', 'Operator', 'Structure',
  },

  extra_groups = {
    -- NeoTree
    -- 'NeoTreeNormal', 'NeoTreeNormalNC',
    -- BufferLine
    -- 'Tabline', 'WildMenu', 'BufferLineFill',
    -- Snacks
    'SnacksPickerInput', 'SnacksPickerInputBorder',
    'SnacksPickerList', 'SnacksPickerListBorder',
  },

  exclude_groups = {},
  on_clear = function() end,
}

function M.setup(opts)
  opts = opts or {}
  config = vim.tbl_extend('force', config, opts)

  if opts.auto_enable then
    vim.api.nvim_create_autocmd('VimEnter', {
      once = true,
      callback = function()
        vim.schedule(function() M.toggle(true) end)
      end,
    })
  end
end

-- [Cache Module] persist state
local cache_path = fn.stdpath('data') .. package.config:sub(1, 1) .. 'transparent_state'
local function cache_read()
  local ok, data = pcall(fn.readfile, cache_path)
  vim.g.bg_transparent = ok and #data > 0 and vim.trim(data[1]) == 'true'
end
local function cache_write() fn.writefile({ tostring(vim.g.bg_transparent) }, cache_path) end
cache_read() -- load state on startup

-- [Core] Clear highlight groups
local function clear_group(group)
  local list = type(group) == 'string' and { group } or group

  for _, g in ipairs(list) do
    if not vim.tbl_contains(config.exclude_groups, g) then
      -- Preserve original highlight (only save on first transparency)
      if ORIGINAL_HL_CACHE[g] == nil then
        local ok, prev = pcall(api.nvim_get_hl, 0, { name = g, link = false })
        if ok and prev then ORIGINAL_HL_CACHE[g] = vim.deepcopy(prev) end
      end

      -- Set transparent
      local ok, prev = pcall(api.nvim_get_hl, 0, { name = g, link = false })
      if ok and prev then
        if prev.bg or prev.ctermbg then
          prev.bg, prev.ctermbg = 'NONE', 'NONE'
          api.nvim_set_hl(0, g, prev)
        end
      end
    end
  end
end

local function do_clear()
  if not vim.g.bg_transparent then return end

  clear_group(config.groups)
  clear_group(config.extra_groups)

  if type(vim.g.transparent_groups) == 'table' then clear_group(vim.g.transparent_groups) end
end

function M.clear()
  if not vim.g.bg_transparent then return end

  do_clear()

  vim.defer_fn(do_clear, 300)
  vim.defer_fn(do_clear, 800)
  vim.defer_fn(do_clear, 1500)
  vim.defer_fn(do_clear, 3000)

  api.nvim_exec_autocmds('User', { pattern = 'TransparentClear', modeline = false })
  config.on_clear()
end

-- [Public API]
function M.enable()
  vim.g.bg_transparent = true
  cache_write()
  M.clear()
end

function M.disable()
  vim.g.bg_transparent = false
  cache_write()

  -- Restore original highlights
  for group, attrs in pairs(ORIGINAL_HL_CACHE) do
    api.nvim_set_hl(0, group, attrs)
  end
  -- Clear cache for next save
  ORIGINAL_HL_CACHE = {}
  -- If the theme plugin reloads the highlight, reset the theme
  if vim.g.colors_name then pcall(vim.cmd.colorscheme, vim.g.colors_name) end
end

function M.toggle(opt)
  if opt ~= nil then
    vim.g.bg_transparent = opt
  else
    vim.g.bg_transparent = not vim.g.bg_transparent
  end

  cache_write()

  if vim.g.bg_transparent then
    M.enable()
  else
    M.disable()
  end
end

-- [Commands & Keymaps]
vim.api.nvim_create_user_command('TransparentEnable', M.enable,
  { desc = 'Enable background transparency' })
vim.api.nvim_create_user_command('TransparentDisable', M.disable,
  { desc = 'Disable background transparency' })
vim.api.nvim_create_user_command('TransparentToggle', M.toggle,
  { desc = 'Toggle background transparency' })
vim.keymap.set('n', '<leader>ut', M.toggle, { desc = 'Toggle transparent background' })

return M
