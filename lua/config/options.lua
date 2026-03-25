local utils = require('libs.utils')

-- [Appearance]
vim.opt.signcolumn = 'yes' -- always show sign column
if utils.is_compatible_version('0.10') then
  vim.opt.termguicolors = true -- enable 24-bit RGB colors
end
vim.opt.winborder = 'rounded'
vim.opt.showmode = false -- Hide mode status
-- Line edit
vim.opt.fillchars = { eob = ' ' }
vim.opt.cursorline = true -- highlight current line
vim.opt.cursorlineopt = 'number'
vim.opt.scrolloff = 4 -- keep 4 lines visible around cursor
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
vim.opt.foldtext = "v:lua.vim.fn.getline(v:foldstart) .. ' …'" -- Fold text

-- [Editor]
vim.opt.cmdheight = 0
vim.opt.fileformat = 'unix'
vim.opt.mouse = 'a' -- enable mouse in all modes

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

-- [Fold] 完美还原 LazyVim 的自动折叠体验
vim.opt.foldlevel = 99 -- 默认展开所有代码（设为 0 会一打开文件全折叠）
vim.opt.foldlevelstart = 99 -- 新开 buffer 时默认打开折叠
vim.opt.foldenable = true -- 允许折叠
vim.opt.foldmethod = 'expr' -- 使用表达式进行折叠（核心！）
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- 叫 Treesitter 自动帮你根据语法树生成折叠

-- [Functions]
-- Clipboard
require('config.clipboard')
-- Check spelling
vim.opt.spell = false
vim.opt.spelllang = { 'en_us', 'ms', 'cjk' }
vim.opt.spellsuggest = 'best,5' -- show only first best 5
vim.opt.spelloptions = 'camel' --support CamelCase
-- vim.opt.spelloptions = 'underscore'
--
