vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [Basic]
-- Quit
vim.keymap.set("n", "<leader>qq", "<Cmd>qa<CR>", { desc = "Quit all" })
-- Save
vim.keymap.set("n", "<leader>w", "<Cmd>w<CR>", { desc = "Save file" })
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<Cmd>w<CR><esc>", { desc = "Save file" })
vim.keymap.set("n", "<leader>wq", "<Cmd>wq<CR>", { desc = "Save and quit" })

-- [View]
vim.keymap.set("n", "<leader>us", '<Cmd>setlocal spell! spell?<CR>', { desc = "Toggle spelling" })
vim.keymap.set('n', '<leader>uw', '<Cmd>setlocal wrap! wrap?<CR>', { desc = "Toggle wrap" })
vim.keymap.set('n', '<leader>ub', '<Cmd>lua vim.o.bg = vim.o.bg == "dark" and "light" or "dark"<CR>',
  { desc = "Toggle background" })

-- [Edit]
-- Indent
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")
-- Comment
vim.keymap.set("n", "gco", "o<esc>Vcx<esc><Cmd>normal gcc<CR>fxa<bs>", { desc = "Add comment below" })
vim.keymap.set("n", "gcO", "O<esc>Vcx<esc><Cmd>normal gcc<CR>fxa<bs>", { desc = "Add comment above" })
-- Move lines
vim.keymap.set("n", "<A-k>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", { desc = "Move up" })
vim.keymap.set("n", "<A-j>", "<Cmd>execute 'move .+' . v:count1<CR>==", { desc = "Move down" })
vim.keymap.set("i", "<A-k>", "<esc><Cmd>m .-2<CR>==gi", { desc = "Move up" })
vim.keymap.set("i", "<A-j>", "<esc><Cmd>m .+1<CR>==gi", { desc = "Move down" })
vim.keymap.set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<CR>gv=gv", { desc = "Move up" })
vim.keymap.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<CR>gv=gv", { desc = "Move down" })
-- Manage buffer
vim.keymap.set("n", "<S-h>", "<Cmd>bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<Cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", function()
  local cur = vim.api.nvim_get_current_buf()
  local alt = vim.fn.bufnr("#")
  if alt > 0 and vim.api.nvim_buf_is_loaded(alt) then
    vim.cmd("buffer #")
  else
    vim.cmd("bnext")
  end
  vim.cmd("bdelete " .. cur)
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and buf ~= current then
      vim.cmd("bdelete " .. buf)
    end
  end
end, { desc = "Delete Other Buffers" })

-- [Window]
vim.keymap.set("n", "<leader>sd", "<C-W>c", { desc = "Delete window", remap = true })
-- Split windows
vim.keymap.set("n", "<leader>ss", "<C-W>s", { desc = "Split window below", remap = true })
vim.keymap.set("n", "<leader>sv", "<C-W>v", { desc = "Split window right", remap = true })
-- Move between windows
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
-- Resize splits
vim.keymap.set('n', '<C-Left>', '"<Cmd>vertical resize -" . v:count1 . "<CR>"',
  { expr = true, replace_keycodes = false, desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Down>', '"<Cmd>resize -"          . v:count1 . "<CR>"',
  { expr = true, replace_keycodes = false, desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Up>', '"<Cmd>resize +"          . v:count1 . "<CR>"',
  { expr = true, replace_keycodes = false, desc = 'Increase window height' })
vim.keymap.set('n', '<C-Right>', '"<Cmd>vertical resize +" . v:count1 . "<CR>"',
  { expr = true, replace_keycodes = false, desc = 'Increase window width' })

-- [Functions]
vim.keymap.set("n", "<leader>fn", "<Cmd>enew<CR>", { desc = "New file" }) -- new file
-- File explorer
-- vim.keymap.set("n", "<leader>e", ":Lexplore<CR>", { desc = "Toggle file explorer" })
-- Terminal
vim.keymap.set("n", "<leader>`", "<Cmd>vert term fish.exe<CR>", { desc = "Open Term" })

-- Search
-- Better n/N behavior https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
vim.keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
-- Clear search and stop snippet on escape
vim.keymap.set({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and clear hlsearch" })

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
