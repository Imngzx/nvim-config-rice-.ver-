-- Github 样式主题
-- https://github.com/projekt0n/github-nvim-theme
return {
  'projekt0n/github-nvim-theme',
  lazy = false,      -- make sure we load this during startup if it is your main colorscheme
  priority = 1000,   -- make sure to load this before all the other start plugins
  config = function()
    require('github-theme').setup {
      options = {
        styles = { comments = 'NONE' },
        darken = {
          sidebars = { enable = true }           -- 启用侧边栏
        },
        modules = {
          -- coc = {
          --   background = true,
          -- },
          diagnostic = {
            -- This is linked to so much that is needs to be enabled. This is here primarily
            -- for the extra options that can be added with modules
            enable = true,
            background = false,
          },
          native_lsp = {
            enable = true,
            background = true,
          },
          treesitter = true,
          lsp_semantic_tokens = true,
        },
      }
    }

    vim.cmd.colorscheme('github_dark_dimmed')
  end,
}
