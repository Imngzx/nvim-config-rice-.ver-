-- nvim/lua/config/options.lua

--[Functions]
-- Clipboard
-- 💥 榨干 Neovim 0.12 API：纯异步的 WSL 跨界剪贴板
if vim.fn.has('wsl') == 1 then
  local win32yank = '/mnt/c/Program Files/Neovim/bin/win32yank.exe'

  -- 先探测一下二进制文件存不存在，防呆保护
  if vim.fn.executable(win32yank) == 1 then
    vim.g.clipboard = {
      name = 'AsyncWslClipboard',
      copy = {
        ['+'] = function(lines, _)
          -- 🛡️ 物理防御：判断是否在机器全速“执行”宏。如果是，直接拦截，拒绝跨越 WSL 边界
          if vim.fn.reg_executing() ~= '' then return end

          local text = table.concat(lines, '\n')
          -- ✨ 你的优雅方案：纯异步 + Libuv 自动句柄回收
          vim.system({ win32yank, '-i', '--crlf' }, { stdin = text }, function() end)
        end,
        ['*'] = function(lines, _)
          if vim.fn.reg_executing() ~= '' then return end

          local text = table.concat(lines, '\n')
          vim.system({ win32yank, '-i', '--crlf' }, { stdin = text }, function() end)
        end,
      },
      paste = {
        ['+'] = function()
          -- 粘贴必须是同步的（因为 Neovim 需要立刻拿到文字），所以这里用 :wait()
          local obj = vim.system({ win32yank, '-o', '--lf' }, { text = true }):wait()
          if obj.code ~= 0 or not obj.stdout then return {}, 'v' end

          local text = obj.stdout
          -- 规避 Windows 剪贴板可能带来的末尾多余空行问题
          if text:sub(-1) == '\n' then text = text:sub(1, -2) end
          return vim.split(text, '\n', { plain = true }), 'v'
        end,
        ['*'] = function()
          local obj = vim.system({ win32yank, '-o', '--lf' }, { text = true }):wait()
          if obj.code ~= 0 or not obj.stdout then return {}, 'v' end

          local text = obj.stdout
          if text:sub(-1) == '\n' then text = text:sub(1, -2) end
          return vim.split(text, '\n', { plain = true }), 'v'
        end,
      },
      cache_enabled = 0,
    }
  end
end

-- 统一设置剪贴板寄存器，使用 schedule 延后执行，不占用启动那一毫秒的时间
vim.schedule(function()
  vim.opt.clipboard = vim.env.SSH_CONNECTION and '' or 'unnamedplus'
end)
