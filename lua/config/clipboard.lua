--[Functions]
if vim.fn.has('wsl') == 1 then
  local win32yank = '/mnt/c/Program Files/Neovim/bin/win32yank.exe'

  if vim.fn.executable(win32yank) == 1 then
    vim.g.clipboard = {
      name = 'AsyncWslClipboard',
      copy = {
        ['+'] = function(lines, _)
          if vim.fn.reg_executing() ~= '' then return end

          local text = table.concat(lines, '\n')
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
          local obj = vim.system({ win32yank, '-o', '--lf' }, { text = true }):wait(1000)
          if obj.code ~= 0 or not obj.stdout then return {}, 'v' end

          local text = obj.stdout
          if text:sub(-1) == '\n' then text = text:sub(1, -2) end
          return vim.split(text, '\n', { plain = true }), 'v'
        end,
        ['*'] = function()
          local obj = vim.system({ win32yank, '-o', '--lf' }, { text = true }):wait(1000)
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

vim.schedule(function()
  vim.opt.clipboard = vim.env.SSH_CONNECTION and '' or 'unnamedplus'
end)
