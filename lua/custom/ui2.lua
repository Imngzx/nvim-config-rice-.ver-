-- 🚀 Neovim 0.12+ Native UI2 Engine
local M = {}

function M.setup()
  local ok, ui2 = pcall(require, 'vim._core.ui2')
  if not ok then return end

  ui2.enable({
    enable = true,
    msg = {
      targets = 'msg',
      timeout = 4000,
    },
  })
end

return M
