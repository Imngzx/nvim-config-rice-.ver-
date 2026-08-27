local M = {}

function M.setup()
  local ok, ui2 = pcall(require, 'vim._core.ui2')
  if not ok then return end

  -- Configure timeout and maxheight via messagesopt (replaces msg.msg.timeout and msg.cmd.height)
  vim.opt.messagesopt:append('timeout:4000')
  vim.opt.messagesopt:append('maxheight:50')

  ui2.enable({
    enable = true,
    msg = {
      targets = 'msg',

      cmd = {},

      msg = {
        height = 0.5,
      },

      dialog = {
        height = 0.5,
      },
    },
  })
end

return M
