-- 语法高亮
-- https://github.com/nvim-treesitter/nvim-treesitter
return {
  "nvim-treesitter/nvim-treesitter",
  version = false, -- last release is way too old and doesn't work on Windows
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "HiPhish/nvim-ts-rainbow2" },
  cmd = { "TSUpdateSync" },
  opts = {
    highlight = {
      enable = true,
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end
    },
    indent = { enable = true },
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
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
    -- 不同括号颜色区分（彩虹括号）
    rainbow = {
      enable = true,
      -- list of languages you want to disable the plugin for
      -- disable = { 'jsx', 'cpp' },
      -- Which query to use for finding delimiters
      query = 'rainbow-parens',
      -- Highlight the entire buffer all at once
      strategy = function()
        return require('ts-rainbow').strategy.global
      end,
      hlgroups = {
        'TSRainbowYellow',
        'TSRainbowBlue',
        'TSRainbowOrange',
        'TSRainbowGreen',
        'TSRainbowViolet',
        'TSRainbowCyan'
      },
    }
  },
}
