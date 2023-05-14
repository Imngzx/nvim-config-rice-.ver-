require('github-theme').setup {
  options = {
    styles = {
      comments = 'NONE',
    },
    darken = {
      sidebars = {
        enable = true -- 启用侧边栏
      }
    },
    modules = {
      -- coc = {
      --   background = true,
      -- },
      -- diagnostic = {
      --   -- This is linked to so much that is needs to be enabled. This is here primarily
      --   -- for the extra options that can be added with modules
      --   enable = true,
      --   background = false,
      -- },
      native_lsp = {
        enable = true,
        background = true,
      },
      treesitter = true,
      lsp_semantic_tokens = true,
    },
  },

  specs = {
    -- Change the color of only the 'github_dark' theme's 'hint' color to magenta and make the 'error' color a dim red.
    github_dimmed = {
      -- bg3 = "NONE"
    },
  }
}

vim.cmd('colorscheme github_dark_dimmed')

