local M = {}

M.is_windows = function()
  return jit.os == 'Windows'
end

M.is_mac = function()
  return jit.os == 'OSX'
end

M.is_penguin = function()
  return jit.os == 'Linux'
end

--- Check if running in WSL
---@return boolean
function M.is_wsl()
  if jit.os ~= 'Linux' then return false end
  local version = vim.fn.readfile('/proc/version')[1] or ''
  return version:lower():match('microsoft') ~= nil
end

--- Check if the current nvim version is compatible with the allowed version
---@param min_version string
---@return boolean
function M.is_compatible_version(min_version)
  return vim.version() >= vim.version.parse(min_version)
end

return M