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
    'SnacksPickerInput', 'SnacksPickerInputBorder',
    'SnacksPickerList', 'SnacksPickerListBorder',
    'SnacksBackdrop', 'SnacksNormal',
    'NormalFloat', 'FloatBorder', 'FloatTitle', 'FloatFooter',
    'BlinkCmpMenu', 'BlinkCmpMenuBorder',
    'BlinkCmpDoc', 'BlinkCmpDocBorder',
    'BlinkCmpSignatureHelp', 'BlinkCmpSignatureHelpBorder',
    'LspInfoBorder', 'WhichKeyFloat',
    'WinBar', 'WinBarNC',
    'DropBarMenuNormalFloat', 'DropBarMenuBorder',
  },

  exclude_groups = {},
  on_clear = function() end,
}

local exclude_set = {}
for _, v in ipairs(config.exclude_groups) do
  exclude_set[v] = true
end

local cache_path = fn.stdpath('data') .. package.config:sub(1, 1) .. 'transparent_state'

local function cache_read()
  local stat = vim.uv.fs_stat(cache_path)
  if stat then
    local fd = vim.uv.fs_open(cache_path, 'r', 438)
    if fd then
      local data = vim.uv.fs_read(fd, stat.size, 0)
      vim.uv.fs_close(fd)
      if data then
        vim.g.bg_transparent = (data:match('true') ~= nil)
        return
      end
    end
  end
  vim.g.bg_transparent = false
end

local function cache_write()
  local dir = vim.fs.dirname(cache_path)
  if not vim.uv.fs_stat(dir) then vim.fs.mkdir(dir, { parents = true }) end
  local fd = vim.uv.fs_open(cache_path, 'w', 438)
  if fd then
    vim.uv.fs_write(fd, tostring(vim.g.bg_transparent), -1)
    vim.uv.fs_close(fd)
  end
end

local function clear_group(group)
  local list = type(group) == 'string' and { group } or group

  for i = 1, #list do
    local g = list[i]
    if not exclude_set[g] then
      local def = api.nvim_get_hl(0, { name = g, link = true })

      if def and not def.link then
        if ORIGINAL_HL_CACHE[g] == nil then
          ORIGINAL_HL_CACHE[g] = vim.deepcopy(def)
        end

        if def.bg or def.ctermbg then
          def.bg = nil
          def.ctermbg = nil
          api.nvim_set_hl(0, g, def)
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

  for i = 1, #M._timers do
    require('snacks').util.stop(M._timers[i])
  end
  M._timers = {}

  do_clear()

  local timer = vim.uv.new_timer()
  if timer then
    timer:start(800, 0, vim.schedule_wrap(function()
      do_clear()
      require('snacks').util.stop(timer)
    end))
    table.insert(M._timers, timer)
  end

  api.nvim_exec_autocmds('User', { pattern = 'TransparentClear', modeline = false })
  config.on_clear()
end

function M.enable()
  vim.g.bg_transparent = true
  cache_write()
  M.clear()
end

function M.disable()
  vim.g.bg_transparent = false
  cache_write()

  for i = 1, #M._timers do
    require('snacks').util.stop(M._timers[i])
  end
  M._timers = {}

  for group, attrs in pairs(ORIGINAL_HL_CACHE) do
    api.nvim_set_hl(0, group, attrs)
  end

  ORIGINAL_HL_CACHE = {}

  vim.cmd('redraw!')
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

function M.setup(opts)
  opts = opts or {}
  config = vim.tbl_extend('force', config, opts)

  cache_read()

  if opts.auto_enable ~= nil then
    if opts.auto_enable then
      vim.g.bg_transparent = true
    else
      vim.g.bg_transparent = false
    end
    cache_write()
  end

  vim.schedule(function()
    if vim.g.bg_transparent then
      M.clear()
    else
      M.disable()
    end
  end)

  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('TransparentThemeSync', { clear = true }),
    callback = function()
      if vim.g.bg_transparent then
        ORIGINAL_HL_CACHE = {}
        M.clear()
      else
        ORIGINAL_HL_CACHE = {}
      end
    end,
  })
end

vim.api.nvim_create_user_command('TransparentEnable', M.enable,
  { desc = 'Enable background transparency' })
vim.api.nvim_create_user_command('TransparentDisable', M.disable,
  { desc = 'Disable background transparency' })
vim.api.nvim_create_user_command('TransparentToggle', M.toggle,
  { desc = 'Toggle background transparency' })
vim.keymap.set('n', '<leader>ut', M.toggle, { desc = 'Toggle transparent background' })

return M
