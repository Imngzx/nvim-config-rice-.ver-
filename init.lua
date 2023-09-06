-- Settings
vim.g.is_windows = true

-- 主设置
require("config.options")

-- 插件
require("plugins.setup")

-- 快捷键
require("config.keymaps")

-- 特殊优化
if not vim.g.vscode then
  -- 透明
  require("config.transparent")
end

-- 其他
-- require("config.cmd")
