return {
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    -- init = function()
    --   vim.g.mkdp_filetypes = { "markdown" }
    -- end,
    keys = {
      {
        "<leader>p",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Toggle markdown preview",
      },
    },
  },
}
