-- 顶栏（窗口管理）
-- https://github.com/akinsho/bufferline.nvim
return {
  "akinsho/bufferline.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = 'nvim-tree/nvim-web-devicons',
  keys = {
    { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>",            desc = "Toggle pin" },
    { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
  },
  opts = function()
    local icons = require("icons")
    local bufferline = require("bufferline")

    return {
      options = {
        always_show_bufferline = false,
        close_command =
            function(num)
              if vim.fn.bufnr('%') == num then
                vim.cmd('BufferLineCyclePrev')
              end
              vim.cmd('bd! ' .. num)
            end,
        right_mouse_command = "vertical sbuffer %d",
        style_preset = bufferline.style_preset.no_italic,
        -- 使用 nvim lsp
        diagnostics = "nvim_lsp",
        offsets = {
          -- 左侧 neotree
          {
            filetype = "neo-tree",
            text = icons.basic.Vim .. " File Explorer",
            highlight = "Directory",
            text_align = "left",
            separator = true
          },
          -- 右侧 Outline
          {
            filetype = "sagaoutline",
            text = icons.basic.Menu .. " Outline",
            highlight = "Directory",
            text_align = "left",
            separator = true
          },
        },
        -- 分隔样式
        indicator = { style = 'none' },
        separator_style = { '│', '│' },
      },
      highlights = {
        separator = { fg = "#768390" },
      },
    }
  end
}
