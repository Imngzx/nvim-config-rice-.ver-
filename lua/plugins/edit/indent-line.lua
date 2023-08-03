-- 缩进线
-- https://github.com/lukas-reineke/indent-blankline.nvim
return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    char = "│",
    filetype_exclude = {
      "help",
      "alpha",
      "dashboard",
      "neo-tree",
      "Trouble",
      "lazy",
      "mason",
      "notify",
      "toggleterm",
      "lazyterm",
    },
    show_trailing_blankline_indent = true,
    show_current_context = true,
    space_char_blankline = " ",
  },
}
