-- 快速注释
-- https://github.com/numToStr/Comment.nvim
return {
  "numToStr/Comment.nvim",
  -- event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("Comment").setup()
  end,
  keys = {
    { "g", mode = "n" },
    { "g", mode = "v" },
  },
}
