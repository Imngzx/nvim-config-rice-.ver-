vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [Basic]
-- Quit
vim.keymap.set('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit all' })
-- Save
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = 'Save file' })
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })
vim.keymap.set('n', '<leader>wq', '<cmd>wq<cr>', { desc = 'Save and quit' })

-- [View]
vim.keymap.set('n', '<leader>us', '<cmd>setlocal spell! spell?<cr>', { desc = 'Toggle spelling' })
vim.keymap.set('n', '<leader>uw', '<cmd>setlocal wrap! wrap?<cr>', { desc = 'Toggle wrap' })
vim.keymap.set('n', '<leader>ub', '<cmd>lua vim.o.bg = vim.o.bg == "dark" and "light" or "dark"<cr>',
  { desc = 'Toggle background' }
)

-- [Edit]
-- Indent
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('x', '>', '>gv')
-- Comment
vim.keymap.set('n', 'gco', 'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add comment below' })
vim.keymap.set('n', 'gcO', 'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add comment above' })
-- Move lines
vim.keymap.set('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move up' })
vim.keymap.set('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move down' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move up' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move down' })
vim.keymap.set('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv",
  { desc = 'Move up' })
vim.keymap.set('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv",
  { desc = 'Move down' })
-- Spelling
vim.keymap.set('n', '<leader>cs', 'z=', { desc = 'Spelling suggestions' })

-- [Buffer]
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev buffer' })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
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
vim.keymap.set('n', '<leader>bo', function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and buf ~= current then vim.cmd('bdelete ' .. buf) end
  end
end, { desc = 'Delete Other Buffers' })
vim.keymap.set('n', '<leader>bn', '<cmd>enew<cr>', { desc = 'New file' }) -- new file

-- [Window]
vim.keymap.set('n', '<leader>pd', '<C-W>c', { desc = 'Delete window', remap = true })
-- Split windows
vim.keymap.set('n', '<leader>ps', '<C-W>s', { desc = 'Split window below', remap = true })
vim.keymap.set('n', '<leader>pv', '<C-W>v', { desc = 'Split window right', remap = true })
-- Move between windows
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<BS>', '<C-w>h', { desc = 'Move to left window' }) -- Fix <c-h> used as <bs> in some terminal
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to below window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to above window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })
-- Resize splits
vim.keymap.set('n', '<C-Left>', '"<cmd>vertical resize -" . v:count1 . "<cr>"',
  { expr = true, replace_keycodes = false, desc = 'Decrease window width' }
)
vim.keymap.set('n', '<C-Down>', '"<cmd>resize -" . v:count1 . "<cr>"',
  { expr = true, replace_keycodes = false, desc = 'Decrease window height' }
)
vim.keymap.set('n', '<C-Up>', '"<cmd>resize +" . v:count1 . "<cr>"',
  { expr = true, replace_keycodes = false, desc = 'Increase window height' }
)
vim.keymap.set('n', '<C-Right>', '"<cmd>vertical resize +" . v:count1 . "<cr>"',
  { expr = true, replace_keycodes = false, desc = 'Increase window width' }
)

-- [Functions]
-- Terminal
vim.keymap.set('n', '<leader>`', '<cmd>vert term fish.exe<cr>', { desc = 'Open Term' })

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
