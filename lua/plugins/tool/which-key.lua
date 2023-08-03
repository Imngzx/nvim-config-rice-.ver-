-- 键盘映射提示
-- https://github.com/folke/which-key.nvim
return {
  "folke/which-key.nvim",
  opts = function(_, opts)
    if require("util").has("noice.nvim") then
      opts.defaults["<leader>sn"] = { name = "+noice" }
    end
  end,
}