-- lua/custom/im-select.lua
local M = {}

function M.setup()
  if vim.fn.executable('fcitx5-remote') == 0 then return end

  local aug = vim.api.nvim_create_augroup('DIY_Fcitx5', { clear = true })

  vim.api.nvim_create_autocmd('InsertLeave', {
    group = aug,
    callback = function()
      -- 1. 同步获取状态（1 为英文，2 为中文）
      local obj = vim.system({ 'fcitx5-remote' }, { text = true }):wait()
      if obj.code == 0 and obj.stdout then
        vim.b.saved_im = vim.trim(obj.stdout)
      end

      vim.system({ 'fcitx5-remote', '-c' }):wait()
    end
  })

  vim.api.nvim_create_autocmd('InsertEnter', {
    group = aug,
    callback = function()
      local target = vim.b.saved_im
      -- 如果刚才退出前是中文状态('2')，则恢复中文
      if target == '2' then
        -- 恢复中文可以用异步，因为慢 1ms 开启不影响你敲代码
        vim.system({ 'fcitx5-remote', '-o' })
      end
    end
  })

  -- 无论是刚打开 Neovim、切换回 Neovim 窗口、还是退出命令行，一律强制纯净英文
  vim.api.nvim_create_autocmd({ 'VimEnter', 'FocusGained', 'CmdlineLeave' }, {
    group = aug,
    callback = function()
      vim.system({ 'fcitx5-remote', '-c' }):wait()
    end
  })
end

return M
