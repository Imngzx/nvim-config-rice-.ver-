local M = {}

M.is_windows = function()
  return vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
end

--- Check if the current nvim version is compatible with the allowed version
--- @param expected_version string
--- @return boolean
function M.is_compatible_version(expected_version)
  return vim.fn.has('nvim-' .. expected_version) == 1
end

return M
