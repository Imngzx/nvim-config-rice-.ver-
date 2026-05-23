-- [Appearance]
vim.opt.signcolumn = 'yes' -- always show sign column
vim.opt.winborder = 'rounded'
vim.opt.showmode = false -- Hide mode status
-- Line edit
vim.opt.fillchars = { eob = ' ' }
vim.opt.cursorline = true -- highlight current line
-- vim.opt.cursorlineopt = 'number'
vim.opt.scrolloff = 4 -- keep 4 lines visible around cursor
vim.opt.scrolloffpad = 1 -- cursor position stays at middle when you go to eob
vim.opt.sidescrolloff = 8 -- keep 8 columns visible horizontally
-- Line number
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4
-- Indent
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.shiftwidth = 2 -- indent size
vim.opt.tabstop = 2 -- tab character width
vim.opt.shiftround = true -- round indent to nearest multiple of shiftwidth
vim.opt.smartindent = true -- auto-indent new lines intelligently
-- Wrap
vim.opt.wrap = true -- default line wrap
vim.opt.linebreak = true -- wrap at word boundary if wrap
vim.opt.breakindent = true -- maintain indent on wrap
-- Others
vim.opt.winminwidth = 5 -- prevent tiny splits
vim.opt.undofile = true

-- [Editor]
vim.opt.cmdheight = 0
vim.opt.fileformat = 'unix'
vim.opt.laststatus = 3 -- global satusline (once you add one)
vim.opt.ruler = false
-- vim.opt.colorcolumn = '80'   -- column ruler
vim.opt.confirm = true -- confirm before quitting unsaved changes

-- Case
vim.opt.ignorecase = true -- case-insensitive by default
vim.opt.incsearch = true -- show search results while typing
vim.opt.smartcase = true -- but smart if uppercase is used

-- Split
vim.opt.splitbelow = true -- horizontal splits below
vim.opt.splitright = true -- vertical splits to the right
vim.opt.splitkeep = 'screen' -- preserve layout when splitting

-- Format
vim.opt.formatoptions =
'jcroqlnt' -- keep comments, wrap text, autoformat when possible

-- Command
vim.opt.inccommand = 'nosplit' -- live preview for :substitute
vim.opt.wildmode = 'longest:full,full' -- enhanced command completion

-- Others
vim.opt.jumpoptions = 'view' -- restore view after jump
vim.opt.virtualedit = 'block' -- allow cursor past EOL in block mode
-- vim.o.formatoptions = vim.o.formatoptions:gsub('[ro]', '') -- break comment new line

-- [Fold]
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
require('plugins.ufo')

-- [Functions]
-- Clipboard
require('config.clipboard')

-- Check spelling
vim.opt.spell = false
vim.opt.spelllang = { 'en_us', 'ms', 'cjk', 'id' }
vim.opt.spellsuggest = 'best,5' -- show only first best 5
vim.opt.spelloptions = 'camel' --support CamelCase
-- vim.opt.spelloptions = 'underscore'

vim.filetype.add({
  extension = {
    mdx = 'markdown.mdx',
  }
})

-- [Mason Path Injection]

-- The reason I did this is because...
-- lspconfig can activate lsp without mason loaded
-- can save up ~200 ms when open a file via nvim directly from terminal prompt
local mason_bin = vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'bin')
local is_windows = require('libs.utils').is_windows()

if is_windows then
  mason_bin = mason_bin:gsub('/', '\\')
end

if not vim.env.PATH:find(mason_bin, 1, true) then
  local sep = is_windows and ';' or ':'
  vim.env.PATH = mason_bin .. sep .. vim.env.PATH
end
