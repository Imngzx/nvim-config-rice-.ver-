local lazy = require('libs.lazy')

-- [Treesitter] (基于最新 main 分支重构版)
lazy.load({
  -- 确保你拉取的是 main 分支的代码（如果是全新的电脑，这里很关键）
  plugin = { { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } },

  -- 依然使用文件触发，坚决不占启动时间
  event = { 'BufReadPre', 'BufNewFile' },

  setup = function()
    -- 1. Windows Zig 编译器防御逻辑 (完美保留你的神操作)
    if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
      if vim.fn.executable('zig') == 1 then
        vim.env.CC = 'zig cc'
        vim.env.CXX = 'zig c++'
      end
    end

    local ts = require('nvim-treesitter')

    -- 2. 核心解析器列表
    local parsers = {
      'c', 'cpp', 'python', 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline',
      'bash', 'json', 'yaml', 'toml', 'rust', 'zig', 'javascript', 'typescript', 'vue',
      'latex', 'html'
    }

    -- 3. 异步安装 (如果是已安装的，这里瞬间跳过，0 损耗)
    ts.install(parsers, { summary = false })

    -- 4. 破解懒加载的核心补丁 🪄
    -- 因为我们是懒加载，这错过了 Neovim 第一时间的 FileType 侦测。
    -- 所以我们要手动告诉 Neovim：“现在立刻把当前文件的 AST 语法树高亮给我跑起来！”
    local bufnr = vim.api.nvim_get_current_buf()
    local filetype = vim.bo[bufnr].filetype
    local lang = vim.treesitter.language.get_lang(filetype)

    if lang then
      -- 启动高亮
      pcall(vim.treesitter.start, bufnr, lang)
      -- 启动基于语法树的智能缩进
      vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      -- 启动基于语法树的代码折叠
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo.foldmethod = 'expr'
    end
  end
})
