require("which-key").setup()

local maps = require("keymaps.config")

require("which-key").register(maps.n, { mode = "n" })
require("which-key").register(maps.v, { mode = "v" })
require("which-key").register(maps.t, { mode = "t" })

