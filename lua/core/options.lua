local opt = vim.opt

-- 基本设置
opt.cursorline = true -- 光标行
-- 行号
opt.number = true
opt.relativenumber = true
opt.wrap = false -- 防止包裹

-- 功能
opt.winminwidth = 5 -- Minimum window width
opt.termguicolors = true -- 终端真色彩
opt.signcolumn = "yes"   -- 左边多一列，用来放debug/插件提示
-- 默认新窗口在右边、下边
opt.splitright = true
opt.splitbelow = true
-- 搜索
opt.ignorecase = true
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically

-- 对接外界
opt.mouse = "a" -- 启用鼠标
opt.clipboard = "unnamedplus" -- 系统剪贴板

-- 数据配置
-- 会话选项
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
-- 缩进
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
-- 弹窗大小
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
-- Which-key 配置需要
opt.timeout = true
opt.timeoutlen = 300
-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- 新版本功能
if vim.fn.has("nvim-0.9.0") == 1 then
  opt.splitkeep = "screen"
  opt.shortmess:append({ C = true })
end
