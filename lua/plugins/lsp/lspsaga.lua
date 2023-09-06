-- LSP 综合体验优化
-- https://github.com/nvimdev/lspsaga.nvim

local icons = require("icons")

return {
  "nvimdev/lspsaga.nvim",
  dependencies = {
    'nvim-treesitter/nvim-treesitter', -- optional
    'nvim-tree/nvim-web-devicons'      -- optional
  },
  event = { "BufReadPost", "BufNewFile" },
  opts = {
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
      actionfix = icons.kind.Spell,
      expand = icons.arrows.ArrowClosed,
      collapse = icons.arrows.ArrowOpen,
      code_action = icons.diagnostics.Hint,
      imp_sign = icons.kind.Implementation,
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
        edit = '<Cr>',
      }
    },
    diagnostic = {
      keys = {
        quit = { "<Esc>", "q" },
      }
    },
    finder = {
      keys = {
        quit = { "<Esc>", "q" },
        toggle_or_open = { "<Tab>", "<Cr>" },
      }
    },
    outline = {
      keys = {
        toggle_or_jump = "<Tab>",
        jump = "<Cr>",
      }
    },
    code_action = {
      extend_gitsigns = true,
      keys = {
        quit = { "<Esc>", "q" },
      }
    }
  },
  keys = {
    { "<leader>cc", vim.lsp.buf.format,                            desc = "Format" },
    { "<leader>cd", "<cmd>Lspsaga peek_definition<cr>",            desc = "Definition" },
    { "<leader>cd", "<cmd>Lspsaga peek_definition<cr>",            desc = "Definition" },
    { "<leader>cf", "<cmd>Lspsaga finder<cr>",                     desc = "Find" },
    { "<leader>ch", "<cmd>Lspsaga hover_doc<cr>",                  desc = "Hover" },
    { "<leader>ca", "<cmd>Lspsaga code_action<cr>",                desc = "Actions" },
    { "<leader>cl", "<cmd>Lspsaga show_line_diagnostics<cr>",      desc = "Line diagnostics" },
    { "<leader>cw", "<cmd>Lspsaga show_workspace_diagnostics<cr>", desc = "Workspace diagnostics" },
    { "<leader>cr", "<cmd>Lspsaga rename<cr>",                     desc = "Rename" },
    { "<leader>o",  "<cmd>Lspsaga outline<cr>",                    desc = "Outline" },
    { "<leader>`f", "<cmd>Lspsaga term_toggle zsh<cr>",            desc = "Toggle float terminal" },
  }
}
