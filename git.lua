local api = vim.api

-- 打开 floating terminal 并运行 lazygit
local function open_lazygit()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- 新建一个不可列出的缓冲区作为终端
  local buf = api.nvim_create_buf(false, true)
  local win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  -- 创建终端并在该缓冲区中运行 lazygit
  local term_chan = vim.fn.termopen('lazygit', { detach = 0 })
  -- 把终端输出连接到我们创建的缓冲区
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  -- 重要：把当前窗口的终端 channel 绑定到缓冲区
  vim.fn.chansend(term_chan, '') -- ensure channel exists

  -- 设为终端模式并聚焦
  api.nvim_command('startinsert')

  -- 绑定关闭快捷键 q 或 <Esc><Esc> 返回到普通模式并关闭浮窗
  api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true })
  api.nvim_buf_set_keymap(buf, 't', '<Esc><Esc>', '<C-\\><C-n><cmd>bd!<CR>', { noremap = true, silent = true })
  api.nvim_buf_set_keymap(buf, 't', 'q', '<C-\\><C-n><cmd>bd!<CR>', { noremap = true, silent = true })
end

-- 映射快捷键：<leader>g 打开 lazygit（可改）
vim.keymap.set('n', '<leader>g', open_lazygit, { noremap = true, silent = true })
