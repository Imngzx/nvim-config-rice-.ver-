local icons = require("icons")

require("lspsaga").setup({
  request_timeout = 2000,
  -- 界面
  preview = {
    lines_above = 0,
    lines_below = 10,
  },
  scroll_preview = {
    scroll_down = "<C-f>",
    scroll_up = "<C-b>",
  },
  ui = {
    title = true,
    devicon = true,
    border = "single", -- Can be single, double, rounded, solid, shadow.
    actionfix = icons.lsp.Spell,
    expand = icons.arrows.ArrowClosed,
    collapse = icons.arrows.ArrowOpen,
    code_action = icons.lsp.CodeAction,
    imp_sign = icons.lsp.Implementation,
  },
  -- 快捷键
  rename = {
    keys = {
      quit = { "<Esc>", "q" },
      select = "<Tab>",
    }
  },
  definition = {
    keys = {
      quit = { "<Esc>", "q" },
    }
  },
  outline = {
    keys = {
      toggle_or_jump = "<Tab>",
      jump = "<Cr>",
    }
  },
})
