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
  if M._wsl_cached ~= nil then
    return M._wsl_cached
  end

  if jit.os ~= 'Linux' then
    M._wsl_cached = false
    return false
  end

  local ok, version = pcall(vim.fn.readfile, '/proc/version')
  M._wsl_cached = ok and version[1] and version[1]:lower():match('microsoft') ~= nil or false
  return M._wsl_cached
end

-- Pre-warm WSL cache at load time (safe context)
M.is_wsl()

--- Check if the current nvim version is compatible with the allowed version
---@param min_version string
---@return boolean
function M.is_compatible_version(min_version)
  return vim.version() >= vim.version.parse(min_version)
end

return M