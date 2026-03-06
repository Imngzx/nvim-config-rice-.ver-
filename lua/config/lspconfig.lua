vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--background-index',
    '-j=8', -- 并发数，根据你的 CPU 调整
    '--clang-tidy',
    '--completion-style=detailed',
    '--function-arg-placeholders',
    '--fallback-style=llvm',
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
    fallbackFlags = {
      '--std=c++26',
      '/EHsc',
    },
  },
})

vim.lsp.config('ruff', {
  capabilities = {
    general = {
      positionEncodings = { 'utf-16' },
    },
  },
  cmd_env = { RUFF_TRACE = 'messages' },
  init_options = {
    settings = {
      logLevel = 'error',
    },
  },
})

vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = 'off',
      },
    },
  },
  capabilities = {
    offsetEncoding = { 'utf-16' },
  },
})

vim.lsp.config('qmlls6', {
  mason = false,
  cmd = { 'qmlls6' },
  filetypes = { 'qml' }

})

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

vim.lsp.config('emmylua_ls', {
  cmd = { 'emmylua_ls' },
  filetypes = { 'lua' },
  root_markers = {
    '.emmyrc.json',
    '.git',
  },
  workspace_required = false,

  -- 👇 核心修正：使用 emmylua 专属的 settings 结构
  settings = {
    emmylua = {
      diagnostics = {
        -- 告诉 EmmyLua 这些是全局变量，不要报错
        globals = { 'vim', 'Snacks', 'MiniPairs' },
        -- 你可以在这里关闭一些过于严格、不符合 Neovim 习惯的警告
        disable = {
          'missing-return',
          'invisible-return',
        }
      },
      workspace = {
        -- 挂载 Neovim 运行环境和你的插件目录，以获取代码补全
        library = {
          vim.env.VIMRUNTIME .. '/lua',
          -- 挂载你的包管理器下载的插件目录 (按你之前的配置路径适配)
          vim.fn.stdpath('data') .. '/site/pack/core/opt',
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
      completion = {
        autoRequire = false, -- 关闭烦人的自动 require
        callSnippet = true, -- 函数补全时带上括号
      },
    },
  },
})
