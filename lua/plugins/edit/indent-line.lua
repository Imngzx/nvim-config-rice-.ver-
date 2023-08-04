-- 缩进线
-- https://github.com/lukas-reineke/indent-blankline.nvim
local icons = require("icons")
return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    char = icons.lines.CentralVertical,
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
    show_current_context = true,
    -- show_current_context_start = true,
    show_trailing_blankline_indent = true,
    space_char_blankline = " ",
    context_patterns = {
      "^if",
      "^table",
      "block",
      "class",
      "for",
      "function",
      "if_statement",
      "import",
      "list_literal",
      "method",
      "selector",
      "type",
      "var",
      "while",
    },
  },
}
