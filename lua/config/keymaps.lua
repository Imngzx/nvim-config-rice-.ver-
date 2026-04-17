vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [Basic]
-- Quit
vim.keymap.set('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit all' })
vim.keymap.set('n', '<leader>qr', '<cmd>restart<cr>', { desc = 'Restart' })

-- Save
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = 'Save file' })
vim.keymap.set('n', '<leader>wq', '<cmd>wq<cr>', { desc = 'Save and quit' })

-- [View]
vim.keymap.set('n', '<leader>us', '<cmd>setlocal spell! spell?<cr>', { desc = 'Toggle spelling' })
vim.keymap.set('n', '<leader>uw', '<cmd>setlocal wrap! wrap?<cr>', { desc = 'Toggle wrap' })
vim.keymap.set('n', '<leader>ub', '<cmd>lua vim.o.bg = vim.o.bg == "dark" and "light" or "dark"<cr>',
  { desc = 'Toggle background' }
)

-- [Edit]
-- Indent
vim.keymap.set({ 'n', 'v' }, 'j', 'gj')
vim.keymap.set({ 'n', 'v' }, 'k', 'gk')

vim.keymap.set('x', '<', '<gv')
vim.keymap.set('x', '>', '>gv')
-- Comment
vim.keymap.set('n', 'gco', 'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add comment below' })
vim.keymap.set('n', 'gcO', 'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add comment above' })
-- Move lines
vim.keymap.set('n', '<a-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move up' })
vim.keymap.set('n', '<a-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move down' })
vim.keymap.set('i', '<a-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move up' })
vim.keymap.set('i', '<a-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move down' })
vim.keymap.set('v', '<a-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv",
  { desc = 'Move up' })
vim.keymap.set('v', '<a-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv",
  { desc = 'Move down' })
-- Spelling
vim.keymap.set('n', '<leader>cs', 'z=', { desc = 'Spelling suggestions' })

-- [Buffer]
vim.keymap.set('n', '<s-h>', '<cmd>bprevious<cr>', { desc = 'Prev buffer' })
vim.keymap.set('n', '<s-l>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
-- vim.keymap.set('n', '<leader>bd', function()
--   local cur = vim.api.nvim_get_current_buf()
--   local alt = vim.fn.bufnr('#')
--   if alt > 0 and vim.api.nvim_buf_is_loaded(alt) then
--     vim.cmd('buffer #')
--   else
--     vim.cmd('bnext')
--   end
--   vim.cmd('bdelete ' .. cur)
-- end, { desc = 'Delete buffer' })
-- vim.keymap.set('n', '<leader>bo', function()
--   local current = vim.api.nvim_get_current_buf()
--   for _, buf in ipairs(vim.api.nvim_list_bufs()) do
--     if vim.api.nvim_buf_is_loaded(buf) and buf ~= current then vim.cmd('bdelete ' .. buf) end
--   end
-- end, { desc = 'Delete Other Buffers' })
vim.keymap.set('n', '<leader>bn', '<cmd>enew<cr>', { desc = 'New file' }) -- new file

-- [Window]
vim.keymap.set('n', '<leader>pd', '<c-w>c', { desc = 'Delete window', remap = true })
-- Split windows
vim.keymap.set('n', '<leader>ps', '<c-w>s', { desc = 'Split window below', remap = true })
vim.keymap.set('n', '<leader>pv', '<c-w>v', { desc = 'Split window right', remap = true })
-- Move between windows
vim.keymap.set('n', '<c-h>', '<c-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<bs>', '<c-w>h', { desc = 'Move to left window' }) -- Fix <c-h> used as <bs> in some terminal
vim.keymap.set('n', '<c-j>', '<c-w>j', { desc = 'Move to below window' })
vim.keymap.set('n', '<c-k>', '<c-w>k', { desc = 'Move to above window' })
vim.keymap.set('n', '<c-l>', '<c-w>l', { desc = 'Move to right window' })
-- Resize splits
vim.keymap.set('n', '<c-left>', function()
  vim.cmd('vertical resize -' .. vim.v.count1)
end, { desc = 'Decrease window width' })

vim.keymap.set('n', '<c-down>', function()
  vim.cmd('resize -' .. vim.v.count1)
end, { desc = 'Decrease window height' })

vim.keymap.set('n', '<c-up>', function()
  vim.cmd('resize +' .. vim.v.count1)
end, { desc = 'Increase window height' })

vim.keymap.set('n', '<c-right>', function()
  vim.cmd('vertical resize +' .. vim.v.count1)
end, { desc = 'Increase window width' })

--[Functions]
-- Terminal
local utils = require('libs.utils')

vim.keymap.set('n', '<leader>pt', function()
  local shell = ''

  if utils.is_windows() then
    if vim.fn.executable('pwsh') == 1 then
      shell = 'pwsh'
    elseif vim.fn.executable('powershell') == 1 then
      shell = 'powershell'
    else
      shell = 'cmd'
    end
  else
    if vim.fn.executable('fish') == 1 then
      shell = 'fish'
    elseif vim.fn.executable('zsh') == 1 then
      shell = 'zsh'
    else
      shell = vim.env.SHELL or 'bash'
    end
  end

  vim.cmd('term ' .. shell)
  -- vim.cmd('split | term ' .. shell)
  -- vim.cmd('vsplit | term ' .. shell)

  vim.cmd('startinsert')
end, { desc = 'Open Smart Terminal' })

-- Search
-- Better n/N behavior https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next search result' })
vim.keymap.set('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next search result' })
vim.keymap.set('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next search result' })
vim.keymap.set('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev search result' })
vim.keymap.set('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev search result' })
vim.keymap.set('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev search result' })
-- Clear search and stop snippet on escape
vim.keymap.set({ 'i', 'n', 's' }, '<esc>',
  function()
    vim.cmd('noh')
    return '<esc>'
  end,
  { expr = true, desc = 'Escape and clear hlsearch' }
)

-- Yazi integragtion
vim.keymap.set('n', '<leader>fy', function()
  require('custom.yazi').open()
end, { desc = 'Find via Yazi (File Manager)' })

-- Package
vim.keymap.set('n', '<leader>pu', function() vim.pack.update() end, { desc = 'Update plugins' })

-- interesting feature...
require('config.color_picker')

-- [Others]
-- -- location list
-- vim.keymap.set("n", "<leader>xl", function()
--   local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
--   if not success and err then
--     vim.notify(err, vim.log.levels.ERROR)
--   end
-- end, { desc = "Location List" })
-- -- quickfix list
-- vim.keymap.set("n", "<leader>xq", function()
--   local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
--   if not success and err then
--     vim.notify(err, vim.log.levels.ERROR)
--   end
-- end, { desc = "Quickfix List" })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- [Jisho 查词] 快捷键绑定
-- 1. Normal 模式：直接查光标下悬浮的日语单词
vim.keymap.set('n', '<leader>tj', function()
  require('custom.jisho').search()
end, { desc = 'Jisho (Word under cursor)' })

-- 2. Visual 模式：查被选中的句子或词
vim.keymap.set('v', '<leader>tj', function()
  vim.cmd('noau normal! "vy')
  local text = vim.fn.getreg('v')
  require('custom.jisho').search(text)
end, { desc = 'Jisho (Selection)' })

-- 3. 命令行模式：你可以随时敲 :Jisho taberu 来查罗马音/单词
vim.api.nvim_create_user_command('Jisho', function(opts)
  require('custom.jisho').search(opts.args)
end, { nargs = '?' })
