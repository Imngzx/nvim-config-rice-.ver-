-- Conventional commit for telescope
-- https://github.com/olacin/telescope-cc.nvim
return {
  "olacin/telescope-cc.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("telescope").load_extension("conventional_commits")
  end,
  keys = {
    { "<leader>gc", "<cmd>Telescope conventional_commits<CR>", desc = "Conventional commit" },
  }
}
