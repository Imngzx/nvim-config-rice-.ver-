-- 缩进线
-- https://github.com/lukas-reineke/indent-blankline.nvim
local icons = require("icons")
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    indent = {
      char = icons.lines.CentralVertical,
    },
  },
}
