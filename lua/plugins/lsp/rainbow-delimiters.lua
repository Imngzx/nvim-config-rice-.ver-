-- 括号配对染色
-- https://github.com/hiphish/rainbow-delimiters.nvim
return {
  "hiphish/rainbow-delimiters.nvim",
  event = "BufReadPre",
  dependencies = "nvim-treesitter",
  config = function()
    require("rainbow-delimiters.setup").setup({
      highlight = {
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
        "RainbowDelimiterRed",
      },
    })
  end,
}
