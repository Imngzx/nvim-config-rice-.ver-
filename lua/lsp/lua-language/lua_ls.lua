vim.lsp.config('lua_ls', {
  -- Use this to add any additional keymaps
  -- for specific lsp servers
  -- ---@type LazyKeysSpec[]
  -- keys = {},
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,
      },
      codeLens = {
        enable = false,
      },
      completion = {
        callSnippet = 'Replace',
      },
      doc = {
        privateName = { '^_' },
      },
      hint = {
        enable = true,
        --   setType = false,
        --   paramType = true,
        --   paramName = 'Disable',
        --   semicolon = 'Disable',
        --   arrayIndex = 'Disable',
      },
    }
  }
})
