-- 键盘映射提示
-- https://github.com/folke/which-key.nvim
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = function()
    require("which-key").register({
      ["<leader>"] = {
        c = { name = "Code" },
        f = { name = "Find" },
        g = {
          name = "Git",
          b = { name = "Blame" },
          s = { name = "Stage" },
          S = { name = "Undo stage" },
          r = { name = "Reset stage" },
        },
        ["`"] = { name = "Terminal" },
      },
    })
  end,
}
