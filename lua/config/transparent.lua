local map = require("util").map
-- 将背景色保存到全局变量中
vim.g.bg_color = vim.fn.synIDattr(vim.fn.hlID("Normal"), "bg")

local groups = { -- table: default groups
  'Normal', 'NormalNC', 'Comment', 'Constant', 'Special',
  'Identifier', 'Statement', 'PreProc', 'Type', 'Underlined',
  'Todo', 'String', 'Function', 'Conditional', 'Repeat',
  'Operator', 'Structure', 'LineNr', 'NonText', 'SignColumn',
  'CursorLineNr', 'EndOfBuffer',
  'NeoTreeNormal', 'NeotreeNormalNC',
}

local function set_background(option)
  for _, group in ipairs(groups) do
    local cmd = 'highlight ' .. group .. ' guibg=' .. option
    vim.cmd(cmd)
  end
end

local function t_enable()
  set_background("NONE")
  vim.g.bg_transparent = true
end

local function t_disable()
  set_background(vim.g.bg_color)
  vim.g.bg_transparent = false
end

local function t_toggle()
  local current_bg_color = vim.opt.background:get()
  if vim.g.bg_transparent then
    t_disable()
  else
    t_enable()
  end
end

-- 命令
local user_cmd = vim.api.nvim_create_user_command
user_cmd("TransparentEnable", t_enable, { bang = false })
user_cmd("TransparentDisable", t_disable, { bang = false })
user_cmd("TransparentToggle", t_toggle, { bang = false })
-- 快捷键
map("n", "<leader>t", "<cmd>TransparentToggle<cr>", { desc = "Transparent toggle" })

-- 默认启用
t_enable()
