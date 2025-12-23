-- [Appearance]
vim.opt.signcolumn = 'yes' -- always show sign column
if vim.fn.has('nvim-0.10') == 0 then
  vim.opt.termguicolors = true -- enable 24-bit RGB colors
end
-- vim.opt.showmode = false -- Hide mode status
-- Line edit
vim.opt.cursorline = true -- highlight current line
vim.opt.scrolloff = 4 -- keep 4 lines visible around cursor
vim.opt.sidescrolloff = 8 -- keep 8 columns visible horizontally
-- Line number
vim.opt.number = true
vim.opt.relativenumber = true
-- Indent
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.shiftwidth = 2 -- indent size
vim.opt.tabstop = 2 -- tab character width
vim.opt.shiftround = true -- round indent to nearest multiple of shiftwidth
vim.opt.smartindent = true -- auto-indent new lines intelligently
-- Wrap
vim.opt.wrap = false -- default not line wrap
vim.opt.linebreak = true -- wrap at word boundary if wrap
vim.opt.breakindent = true -- maintain indent on wrap
-- Others
vim.opt.winminwidth = 5 -- prevent tiny splits

-- [Editor]
vim.opt.fileformat = 'unix'
vim.opt.mouse = 'a' -- enable mouse in all modes
vim.opt.laststatus = 3 -- global satusline (once you add one)
vim.opt.colorcolumn = '80' -- column ruler
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
-- Fold https://www.jackfranklin.co.uk/blog/code-folding-in-vim-neovim/
vim.opt.foldmethod = 'expr'
-- Fold expr are on `config/autocommands`
-- vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldcolumn = '0'
vim.opt.foldlevel = 99
vim.opt.foldtext = '' -- make fold preview be syntax highlighted
-- vim.opt.foldtext = "v:lua.vim.fn.getline(v:foldstart) .. ' …'" -- fold text
vim.opt.foldlevelstart = 5
vim.opt.foldnestmax = 6 -- levels that won't be broken down into more granular folds
-- Others
vim.opt.jumpoptions = 'view' -- restore view after jump
vim.opt.virtualedit = 'block' -- allow cursor past EOL in block mode
vim.opt.formatoptions = vim.o.formatoptions:gsub('[ro]', '') -- break comment new line

-- [Functions]
-- Clipboard
vim.opt.clipboard = vim.env.SSH_CONNECTION and '' or 'unnamedplus'
-- Check spelling
vim.opt.spell = true
vim.opt.spelllang = 'en_us'
vim.opt.spellsuggest = 'best,5' -- show only first best 5
vim.opt.spelloptions = 'camel' --support CamelCase
-- vim.opt.spelloptions = 'underscore'
