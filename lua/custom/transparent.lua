-- Transparent background
-- Highly optimized for Neovim 0.12+ (Safe Libuv Timer Management & Cache Sync)

local M = {}
local api, fn = vim.api, vim.fn
local ORIGINAL_HL_CACHE = {}

M._timers = {}

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
    -- Snacks
    'SnacksPickerInput', 'SnacksPickerInputBorder',
    'SnacksPickerList', 'SnacksPickerListBorder',
    'SnacksBackdrop',
    'SnacksNormal',
    -- Neovim 浮窗三剑客
    'NormalFloat', 'FloatBorder', 'FloatTitle', 'FloatFooter',
    -- Blink.cmp
    'BlinkCmpMenu', 'BlinkCmpMenuBorder',
    'BlinkCmpDoc', 'BlinkCmpDocBorder',
    'BlinkCmpSignatureHelp', 'BlinkCmpSignatureHelpBorder',
    -- LSP & WhichKey
    'LspInfoBorder',
    'WhichKeyFloat',
    -- WinBar & DropBar
    'WinBar', 'WinBarNC',
    'DropBarMenuNormalFloat', 'DropBarMenuBorder',
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

  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('TransparentThemeSync', { clear = true }),
    callback = function()
      if vim.g.bg_transparent then
        ORIGINAL_HL_CACHE = {}
        M.clear()
      end
    end,
  })
end

-- [Cache Module] persist state
local cache_path = fn.stdpath('data') .. package.config:sub(1, 1) .. 'transparent_state'

local function cache_read()
  local ok, data = pcall(fn.readfile, cache_path)
  vim.g.bg_transparent = ok and #data > 0 and vim.trim(data[1]) == 'true'
end

local function cache_write()
  local dir = fn.fnamemodify(cache_path, ':h')
  if fn.isdirectory(dir) == 0 then fn.mkdir(dir, 'p') end
  fn.writefile({ tostring(vim.g.bg_transparent) }, cache_path)
end

cache_read() -- load state on startup

-- [Core] Clear highlight groups
local function clear_group(group)
  local list = type(group) == 'string' and { group } or group

  for _, g in ipairs(list) do
    if not vim.tbl_contains(config.exclude_groups, g) then
      local ok, prev = pcall(api.nvim_get_hl, 0, { name = g, link = false })
      if ok and prev then
        -- Preserve original highlight (only save on first transparency)
        if ORIGINAL_HL_CACHE[g] == nil then
          ORIGINAL_HL_CACHE[g] = vim.deepcopy(prev)
        end

        -- Set transparent (Neovim API standard)
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

  for _, t in ipairs(M._timers) do
    pcall(function()
      if t and not t:is_closing() then t:close() end
    end)
  end
  M._timers = {}

  do_clear()

  local timer = vim.uv.new_timer()
  if timer then
    timer:start(800, 0, vim.schedule_wrap(function()
      do_clear()
      pcall(function()
        if not timer:is_closing() then timer:close() end
      end)
    end))
    table.insert(M._timers, timer)
  end

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

  for _, t in ipairs(M._timers) do
    pcall(function()
      if t and not t:is_closing() then t:close() end
    end)
  end
  M._timers = {}

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
