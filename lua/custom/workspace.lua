-- workspace.lua
local M = {}

function M.setup()
  local cwd = vim.uv.cwd()
  if not cwd then return end

  local matches = vim.fs.find('.nvim.lua', { path = cwd, upward = true, limit = 1 })
  local local_config = matches[1]

  if not local_config then return end

  local utils = require('libs.utils')
  if utils.is_windows() then
    local_config = vim.fs.normalize(local_config)
  end

  if vim.uv.fs_stat(local_config) then
    local content = vim.secure.read(local_config)

    if type(content) == 'string' and content ~= '' then
      local chunk, syntax_err = load(content, '@' .. local_config)

      if not chunk then
        vim.notify(
          string.format('\n[Workspace] Syntax error in %s:\n%s', local_config, syntax_err),
          vim.log.levels.ERROR
        )
        return
      end

      local ok, exec_err = xpcall(chunk, debug.traceback)
      if not ok then
        vim.notify(
          string.format('\n[Workspace] Execution error in %s:\n%s', local_config, exec_err),
          vim.log.levels.ERROR
        )
      end
    end
  end
end

return M
