local Util = require("util")
local map = Util.map

-- Windows
-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })
-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
-- Split window
map("n", "<leader>v", "<C-w>v", { desc = "Split vertically" })   -- 右侧新增窗口
map("n", "<leader>s", "<C-w>s", { desc = "Split horizontally" }) -- 底部新增窗口

-- Buffers
if Util.has("bufferline.nvim") then
  map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
  map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
  map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
  map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
  map("n", "<leader>b", "<cmd>BufferLineCyclePrev<cr><cmd>bd #<cr>", { desc = "Close buffer" })        -- 关闭
  map("n", "<leader>B", "<cmd>BufferLineCyclePrev<cr><cmd>bd! #<cr>", { desc = "Close buffer force" }) -- 关闭
else
  map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
  map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
  map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
  map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
end
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Quick actions
-- Wrap Line
map("n", "<leader>x", "<cmd>set invwrap<cr>", { desc = "Toggle wrap" }) -- 切换是否自动换行
-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })
-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })
-- Save file
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
-- Quit
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all" })

-- Terminal
map("n", "<leader>``", "<C-w>s<cmd>term zsh<cr>", { desc = "Split terminal" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit ter mode" })
