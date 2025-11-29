-- [Appearance]
vim.opt.termguicolors = true -- enable 24-bit RGB colors
vim.opt.signcolumn = "yes"   -- always show sign column
-- vim.opt.showmode = false -- Hide mode status
-- Line edit
vim.opt.cursorline = true  -- highlight current line
vim.opt.scrolloff = 4      -- keep 4 lines visible around cursor
vim.opt.sidescrolloff = 8  -- keep 8 columns visible horizontally
-- Indent
vim.opt.expandtab = true   -- use spaces instead of tabs
vim.opt.shiftwidth = 2     -- indent size
vim.opt.tabstop = 2        -- tab character width
vim.opt.shiftround = true  -- round indent to nearest multiple of shiftwidth
vim.opt.smartindent = true -- auto-indent new lines intelligently
-- Line number
vim.opt.number = true
-- Wrap
vim.opt.wrap = false -- default not line wrap
vim.opt.linebreak = true -- wrap at word boundary if wrap
vim.opt.breakindent = true -- maintain indent on wrap
-- Others
vim.opt.winminwidth = 5 -- prevent tiny splits
vim.opt.foldtext = "v:lua.vim.fn.getline(v:foldstart) .. ' …'" -- Fold text

-- [Editor]
vim.opt.fileformat = "unix"
vim.opt.mouse = "a"                    -- enable mouse in all modes
vim.opt.laststatus = 3                 -- global statusline (once you add one)
vim.opt.colorcolumn = "80"             -- column ruler
vim.opt.confirm = true                 -- confirm before quitting unsaved changes
-- Case
vim.opt.ignorecase = true              -- case-insensitive by default
vim.opt.smartcase = true               -- but smart if uppercase is used
-- Split
vim.opt.splitbelow = true              -- horizontal splits below
vim.opt.splitright = true              -- vertical splits to the right
vim.opt.splitkeep = "screen"           -- preserve layout when splitting
-- Format
vim.opt.formatoptions = "jcroqlnt"     -- keep comments, wrap text, autoformat when possible
-- Command
vim.opt.inccommand = "nosplit"         -- live preview for :substitute
vim.opt.wildmode = "longest:full,full" -- enhanced command completion
-- Others
vim.opt.jumpoptions = "view"           -- restore view after jump
vim.opt.virtualedit = "block"          -- allow cursor past EOL in block mode

-- [Functions]
-- Clipboard
vim.opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"
-- Check spelling
vim.opt.spell = true
vim.opt.spelllang = "en_us"
-- File tree
-- vim.cmd("let g:netrw_banner=0") -- disable banner
vim.cmd("let g:netrw_liststyle=3") -- tree view list style

-- [Auto commands]
-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("lazyvim_highlight_yank", { clear = true }),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})
-- Change EOL format to unix on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function()
    -- Remove CR (0x0D)
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for i, l in ipairs(lines) do
      if l:find('\r') then lines[i] = l:gsub('\r', '') end
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end,
})
