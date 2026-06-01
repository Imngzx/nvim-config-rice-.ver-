local M = {}

M.is_windows = function()
  return jit.os == 'Windows'
end

--- Check if the current nvim version is compatible with the allowed version
--- @param version string
--- @return boolean
function M.is_compatible_version(min_version)
  return vim.version.le(min_version, vim.version())
end

return M
