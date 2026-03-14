return {
  -- 1. 原本 lua_ls 的配置
  lua_ls = {
    mason_name = 'lua-language-server',
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        codeLens = { enable = false },
        completion = { callSnippet = 'Replace' },
        doc = { privateName = { '^_' } },
        hint = { enable = true },
      }
    }
  },

  -- 2. 原本 emmylua_ls 的配置
  emmylua_ls = {
    cmd = { 'emmylua_ls' },
    filetypes = { 'lua' },
    root_markers = {
      '.emmyrc.json',
      '.git',
    },
    workspace_required = false,
    settings = {
      emmylua = {
        diagnostics = {
          globals = { 'vim', 'Snacks', 'MiniPairs' },
          disable = { 'missing-return', 'invisible-return' }
        },
        workspace = {
          library = {
            vim.env.VIMRUNTIME .. '/lua',
            vim.fn.stdpath('data') .. '/site/pack/core/opt',
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
        completion = {
          autoRequire = false,
          callSnippet = true,
        },
      },
    },
  }
}
