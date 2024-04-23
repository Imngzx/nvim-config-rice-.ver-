-- Github 样式主题
-- https://github.com/projekt0n/github-nvim-theme
return {
  "projekt0n/github-nvim-theme",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  -- build = ":GithubThemeCompile", -- lua api version
  config = function()
    require("github-theme").setup({
      options = {
        modules = {
          diagnostic = {
            -- This is linked to so much that is needs to be enabled. This is here primarily
            -- for the extra options that can be added with modules
            enable = true,
            background = false,
          },
          treesitter = true,
          gitsigns = true,
          neotree = true,
          telescope = true,
          dashboard = true,
          -- indent_blankline = true,
          whichkey = true,
        },
      },
    })

    vim.cmd.colorscheme("github_dark_dimmed")
  end,
}
