-- 插件安装&懒加载
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- import any modules here
    -- 针对 VSCode-nvim 适配 --
    { import = "plugins.extras.vscode" },
    -- 常规插件
    { import = "plugins.ui" },
    { import = "plugins.edit" },
    { import = "plugins.tool" },
    { import = "plugins.lsp" },
    -- 特殊插件 --
    -- 输入法自动切换
    { import = "plugins.extras.im-select" },
    -- 针对专门的语言做特殊适配
    { import = "plugins.extras.clangd" },
    -- { import = "plugins.extras.python" },
    -- { import = "plugins.extras.markdown" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "github_dark_dimmed" } },
  checker = { enabled = false }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
