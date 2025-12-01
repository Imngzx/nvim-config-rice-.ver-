-- [Config]
require("config.options")
require("config.keymaps")
-- [Plugins]
require("custom.theme").setup() -- theme must be set before plugins
require("plugins.ui")
require("plugins.lsp")
require("plugins.tool")
-- [Custom]
require("custom.transparent").setup({ auto_enable = true })
require("custom.git")
require("custom.pairs")
require("custom.statusline")
