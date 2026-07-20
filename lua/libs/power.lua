local M = {}

local uv = vim.uv
local fn = vim.fn
local pcall = pcall
local sched = vim.schedule
local sys = vim.system

M.config = {
  enable_auto_switch = true,
  default_to_ac = true,
}

local cache_path = fn.stdpath('state') .. '/power_state.cache'
local _is_ac = M.config.default_to_ac

local function read_cache_fast()
  local fd = uv.fs_open(cache_path, 'r', 438)
  if fd then
    local data = uv.fs_read(fd, 2, 0)
    uv.fs_close(fd)
    if data then _is_ac = (data == '1') end
  end
end

local function verify_and_notify(actual_ac)
  if actual_ac ~= _is_ac then
    _is_ac = actual_ac
    uv.fs_open(cache_path, 'w', 438, function(_, fd)
      if fd then
        uv.fs_write(fd, actual_ac and '1' or '0', -1, function()
          uv.fs_close(fd)
        end)
      end
    end)

    local msg = actual_ac
      and '🔌 [Power] AC detected. Restart Neovim to initialize High-Perf Pickers (Snacks).'
      or '🔋 [Power] Battery detected. Restart Neovim to initialize Low-Power Pickers (Fzf-lua).'

    sched(function()
      vim.notify(msg, vim.log.levels.WARN, { title = 'Engine Switch' })
    end)
  end
end

local function check_linux()
  uv.fs_open('/sys/class/power_supply/AC/online', 'r', 438, function(err, fd)
    if err or not fd then
      uv.fs_open('/sys/class/power_supply/ACAD/online', 'r', 438, function(err2, fd2)
        if err2 or not fd2 then return end
        uv.fs_read(fd2, 2, 0, function(_, data)
          uv.fs_close(fd2)
          if data then verify_and_notify(data:sub(1, 1) == '1') end
        end)
      end)
      return
    end
    uv.fs_read(fd, 2, 0, function(_, data)
      uv.fs_close(fd)
      if data then verify_and_notify(data:sub(1, 1) == '1') end
    end)
  end)
end

local function check_windows()
  local ok, ffi = pcall(require, 'ffi')
  if not ok then return end

  if not pcall(function() return ffi.typeof('SYSTEM_POWER_STATUS') end) then
    pcall(ffi.cdef, [[
      typedef struct _SYSTEM_POWER_STATUS {
        unsigned char ACLineStatus;
        unsigned char BatteryFlag;
        unsigned char BatteryLifePercent;
        unsigned char SystemStatusFlag;
        unsigned long BatteryLifeTime;
        unsigned long BatteryFullLifeTime;
      } SYSTEM_POWER_STATUS;
      bool GetSystemPowerStatus(SYSTEM_POWER_STATUS *lpSystemPowerStatus);
    ]])
  end

  pcall(function()
    local status = ffi.new('SYSTEM_POWER_STATUS')
    if ffi.C.GetSystemPowerStatus(status) then
      ---@diagnostic disable-next-line: undefined-field
      local ac = status.ACLineStatus
      verify_and_notify(ac == 1 or ac == 255)
    end
  end)
end

local function check_mac()
  sys({ 'pmset', '-g', 'batt' }, { text = true }, function(obj)
    if obj.code == 0 and obj.stdout then
      verify_and_notify(obj.stdout:find('AC Power') ~= nil)
    end
  end)
end

function M.is_ac()
  if not M.config.enable_auto_switch then return M.config.default_to_ac end
  return _is_ac
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  if not M.config.enable_auto_switch then return end

  read_cache_fast()

  local utils = require('libs.utils')
  local checker = utils.is_penguin() and check_linux
    or utils.is_windows() and check_windows
    or utils.is_mac() and check_mac or function() end

  vim.defer_fn(checker, 100)

  vim.api.nvim_create_autocmd('FocusGained', {
    group = vim.api.nvim_create_augroup('LibPowerStateCheck', { clear = true }),
    callback = function() checker() end,
  })
end

return M
