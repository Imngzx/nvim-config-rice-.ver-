local M = {}

function M.open()
  if vim.fn.executable('yazi') == 0 then
    vim.notify('Yazi is not installed or not in PATH!', vim.log.levels.ERROR)
    return
  end

  local tmpfile = vim.fn.tempname()

  -- 🚀 仅调用 Snacks.win 作为 UI 容器，不干扰内部机制
  local win = require('snacks').win({
    position = 'float',
    width = 0.8,
    height = 0.8,
    border = 'rounded',
    backdrop = 100,
    title = ' 󰇥 Yazi ',
    title_pos = 'center',
    zindex = 45,
    enter = true,
  })

  vim.fn.jobstart(string.format('yazi --chooser-file="%s"', tmpfile), {
    term = true,
    on_exit = function(_, code, _)
      vim.schedule(function()
        win:close()

        -- 完美复用文件读取与跳转逻辑
        if code == 0 and vim.fn.filereadable(tmpfile) == 1 then
          local filenames = vim.fn.readfile(tmpfile)
          if filenames and #filenames > 0 then
            for i, target_file in ipairs(filenames) do
              local escaped_file = vim.fn.fnameescape(target_file)
              if i == 1 then
                vim.cmd('edit ' .. escaped_file)
              else
                vim.cmd('badd ' .. escaped_file)
              end
            end
          end
          vim.fn.delete(tmpfile)
        end
      end)
    end
  })

  vim.cmd('startinsert')

  vim.keymap.set('t', '<Esc><Esc>', '<Esc><Esc>', { buffer = win.buf, nowait = true })
  vim.keymap.set('t', '<C-\\><C-n>', '<NOP>', { buffer = win.buf, nowait = true })
end

return M
