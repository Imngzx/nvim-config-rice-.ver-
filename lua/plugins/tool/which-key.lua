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
    require("which-key").add({
      { "<leader>`", group = "Terminal" },
      { "<leader>c", group = "Code" },
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
      { "<leader>gS", group = "Undo stage" },
      { "<leader>gb", group = "Blame" },
      { "<leader>gr", group = "Reset stage" },
      { "<leader>gs", group = "Stage" },
    })
  end,
}
