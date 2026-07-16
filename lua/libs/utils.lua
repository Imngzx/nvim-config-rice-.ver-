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

--- Check if the current nvim version is compatible with the allowed version
---@param version string
---@return boolean
function M.is_compatible_version(min_version)
  return vim.version() >= vim.version.parse(min_version)
end

return M
