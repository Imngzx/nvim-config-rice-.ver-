local M = {}

M.is_windows = function()
  return jit.os == 'Windows'
end

--- Check if the current nvim version is compatible with the allowed version
--- @param version string
--- @return boolean
function M.is_compatible_version(version)
  -- Old method
  -- return vim.fn.has(string.format('nvim-%s', expected_version)) == 0
  -- New method
  -- https://neovim.io/doc/user/lua/#vim.version.le()
  return vim.version.le(vim.version(), version)
end

return M
