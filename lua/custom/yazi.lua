local M = {}

function M.open()
  -- 🛡️ 物理防御：检查系统有没有装 Yazi，没装直接拦截并优雅提示，防止终端报丑陋的错
  if vim.fn.executable('yazi') == 0 then
    vim.notify('Yazi is not installed or not in PATH!', vim.log.levels.ERROR)
    return
  end

  local tmpfile = vim.fn.tempname()

  -- 动态计算居中尺寸，并防止终端太小导致越界
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  if width < 20 then width = 20 end
  if height < 10 then height = 10 end

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
    title = ' 󰇥 Yazi ',
    title_pos = 'center',
    zindex = 45,
  })

  -- 开启终端并运行 Yazi
  vim.fn.termopen(string.format('yazi --chooser-file="%s"', tmpfile), {
    on_exit = function(_, code, _)
      -- 调度到主线程，防止底层异步线程操作 UI 崩溃
      vim.schedule(function()
        -- 阅后即焚：清理窗口和 Buffer
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
        if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end

        -- 如果正常退出且临时文件存在，说明用户选中了文件
        if code == 0 and vim.fn.filereadable(tmpfile) == 1 then
          local filenames = vim.fn.readfile(tmpfile)
          if filenames and #filenames > 0 then
            -- 遍历选中的文件（支持 Yazi 的多选）
            for i, target_file in ipairs(filenames) do
              local escaped_file = vim.fn.fnameescape(target_file)
              if i == 1 then
                -- 第一个文件直接在当前窗口打开
                vim.cmd('edit ' .. escaped_file)
              else
                -- 其余文件加入后台 Buffer
                vim.cmd('badd ' .. escaped_file)
              end
            end
          end
          vim.fn.delete(tmpfile)
        end
      end)
    end
  })

  -- 自动进入终端输入模式
  vim.cmd('startinsert')

  -- 🔒 彻底锁死 Insert 模式，劫持退出键，强制用户只能通过 Yazi 自身的 q 或者 Enter 退出
  vim.keymap.set('t', '<Esc><Esc>', '<Esc><Esc>', { buffer = buf, nowait = true })
  vim.keymap.set('t', '<C-\\><C-n>', '<NOP>', { buffer = buf, nowait = true })
end

return M
