local opt = vim.opt

-- Basic Settings
opt.cursorline = true -- Highlight cursor line
opt.fileformats = { "unix" } -- Set line endings to LF
opt.number = true -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.wrap = false -- Disable line wrapping
vim.g.mapleader = " " -- Set leader key

-- Functionality
opt.termguicolors = true -- Enable true colors in the terminal
opt.signcolumn = "yes" -- Always show signcolumn
opt.splitright = true -- Open new split windows to the right
opt.splitbelow = true -- Open new split windows below
opt.ignorecase = true -- Ignore case when searching
opt.smartcase = true -- Use smart case when searching
opt.smartindent = true -- Enable smart indenting

-- Interface
opt.mouse = "a" -- Enable mouse support
opt.mousescroll = "ver:1" -- Set mouse scroll lines
opt.clipboard = "unnamedplus" -- Use system clipboard

-- Data Configuration
opt.winminwidth = 5 -- Minimum window width
opt.sessionoptions = { -- Session options
  "buffers",
  "curdir",
  "tabpages",
  "winsize",
}

-- Indentation
opt.tabstop = 2 -- Tab width
opt.shiftwidth = 2 -- Indent width
opt.expandtab = true -- Use spaces instead of tabs
opt.autoindent = true -- Enable auto-indenting

-- Popup Settings
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup

-- Which-key Settings
opt.timeout = true -- Enable timeout
opt.timeoutlen = 300 -- Timeout length

-- Fix Markdown Indentation Settings
vim.g.markdown_recommended_style = 0

-- Additional settings for new version
if vim.fn.has("nvim-0.9.0") then
  opt.splitkeep = "screen" -- Keep split window in screen
  opt.shortmess:append({ C = true }) -- Hide completion messages quickly
end
