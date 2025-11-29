-- [Config]
require("config.options")
require("config.keymaps")
-- [Plugins]
require("plugins.ui")
require("plugins.lsp")
require("plugins.tool")
-- [Custom]
require("custom.transparent").setup({ auto_enable = true })
require("custom.git")
require("custom.pairs")
