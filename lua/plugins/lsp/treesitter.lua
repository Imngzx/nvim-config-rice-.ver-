-- 语法高亮
-- https://github.com/nvim-treesitter/nvim-treesitter
return {
  "nvim-treesitter/nvim-treesitter",
  version = false, -- last release is way too old and doesn't work on Windows
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "TSUpdateSync" },
  keys = {
    { "<c-space>", desc = "Increment selection" },
    { "<bs>", desc = "Decrement selection", mode = "x" },
  },
  opts = {
    highlight = {
      enable = true,
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    },
    indent = { enable = true },
    ensure_installed = {
      -- 静态文件
      "vim",
      "vimdoc",
      "lua", -- Neovim 自身
      "markdown",
      "markdown_inline", -- Markdown
      "json",
      "yaml",
      "toml", -- 数据存储
      "gitignore",
      "dockerfile", -- 其他

      -- 脚本文件
      "bash",

      -- 编程语言
      "c",
      "cpp",
      "cmake",
      "qmljs", -- C/Cpp/Qt
      "matlab", -- Matlab
      "java", -- Java
      "python", -- Python
      "r", -- R
      "sql", -- SQL

      -- 前端
      "html",
      "javascript",
      "typescript",
      "css", -- HTML/JS/TS/CSS
      "vue", -- Vue
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
  },
  config = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      ---@type table<string, boolean>
      local added = {}
      opts.ensure_installed = vim.tbl_filter(function(lang)
        if added[lang] then
          return false
        end
        added[lang] = true
        return true
      end, opts.ensure_installed)
    end
    require("nvim-treesitter.configs").setup(opts)
  end,
}
