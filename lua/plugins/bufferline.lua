local bufferline_ok, bufferline = pcall(require, "bufferline")
if not bufferline_ok then
  return
end

local icons = require("icons")

bufferline.setup {
  options = {
    close_command =
        function(num)
          if vim.fn.bufnr('%') == num then
            vim.cmd('BufferLineCyclePrev')
          end
          vim.cmd('bd! ' .. num)
        end,
    right_mouse_command = "vertical sbuffer %d",
    style_preset = bufferline.style_preset.no_italic,
    -- 使用 nvim 内置lsp
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
  }
}
