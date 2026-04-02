-- lua/custom/im-select.lua
local M = {}

function M.setup()
  -- 防呆：如果没有安装 fcitx5-remote，直接静默退出，不报错
  if vim.fn.executable('fcitx5-remote') == 0 then return end

  local aug = vim.api.nvim_create_augroup('DIY_Fcitx5', { clear = true })

  -- 【核心 1：离开 Insert 模式】
  vim.api.nvim_create_autocmd('InsertLeave', {
    group = aug,
    callback = function()
      -- 1. 同步获取状态（1 为英文，2 为中文）
      local obj = vim.system({ 'fcitx5-remote' }, { text = true }):wait()
      if obj.code == 0 and obj.stdout then
        vim.b.saved_im = vim.trim(obj.stdout)
      end

      -- 2. ⚡【致命修复】同步执行关闭指令！
      -- 必须加上 :wait()，强制 Neovim 等待 fcitx5 彻底关闭。
      -- 这样就算你 Esc 和 k 是一起按下去的，也绝对不会被打出中文。
      vim.system({ 'fcitx5-remote', '-c' }):wait()
    end
  })

  -- 【核心 2：进入 Insert 模式】
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

  -- 【核心 3：兜底安全策略】
  -- 无论是刚打开 Neovim、切换回 Neovim 窗口、还是退出命令行，一律强制纯净英文
  vim.api.nvim_create_autocmd({ 'VimEnter', 'FocusGained', 'CmdlineLeave' }, {
    group = aug,
    callback = function()
      vim.system({ 'fcitx5-remote', '-c' }):wait()
    end
  })
end

return M
