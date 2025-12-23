-- [Config]
require("config.options")
require("config.keymaps")
require("config.autocommands")

-- [Plugins]
require("custom.theme").setup() -- theme must be set before plugins
require("plugins.ui")
require("plugins.lsp")
require("plugins.tool")

-- [Custom]
-- UI
require("custom.transparent").setup({ auto_enable = true })
require("custom.statusline")
-- Edit
require("custom.pairs").setup()
require("custom.indent").setup()
-- Tool
require("custom.git")
