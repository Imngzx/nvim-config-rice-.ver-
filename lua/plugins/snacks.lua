local pic = require("custom.char-pic").stay_hungry

return {
  "snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = table.concat(pic, "\n"),
      },
    },
  },
}
