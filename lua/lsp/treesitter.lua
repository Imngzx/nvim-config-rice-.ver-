require("nvim-treesitter.configs").setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = {
    -- 静态文件
    "vim", "vimdoc", "lua",        -- Neovim 自身
    "markdown", "markdown_inline", -- Markdown
    "json", "yaml", "toml",        -- 数据存储
    "gitignore", "dockerfile",     -- 其他

    -- 脚本文件
    "bash",

    -- 编程语言
    "c", "cpp", "cmake", "qmljs", -- C/Cpp/Qt
    "matlab",                     -- Matlab
    "java",                       -- Java
    "python",                     -- Python
    "r",                          -- R
    "sql",                        -- SQL

    -- 前端
    "html", "javascript", "typescript", "css", -- HTML/JS/TS/CSS
    "vue",                                     -- Vue
  },

  highlight = {
    enable = true,
    -- list of language that will be disabled
    -- disable = { "c", "rust" },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end
  },
  indent = { enable = true },

  -- 不同括号颜色区分（彩虹括号）
  rainbow = {
    enable = true,
    -- list of languages you want to disable the plugin for
    -- disable = { 'jsx', 'cpp' },
    -- Which query to use for finding delimiters
    query = 'rainbow-parens',
    -- Highlight the entire buffer all at once
    strategy = require('ts-rainbow').strategy.global,
    hlgroups = {
      'TSRainbowYellow',
      'TSRainbowBlue',
      'TSRainbowOrange',
      'TSRainbowGreen',
      'TSRainbowViolet',
      'TSRainbowCyan'
    },
  }
}
