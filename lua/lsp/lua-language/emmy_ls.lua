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
