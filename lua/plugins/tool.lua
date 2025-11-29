local icons = require("custom.icons")

-- [Key note]
vim.pack.add({ "https://github.com/folke/which-key.nvim" })
require("which-key").add({
  { "<leader>b", group = "Buffer" },
  { "<leader>c", group = "Code" },
  { "<leader>s", group = "Session" },
  { "<leader>f", group = "File" },
})
vim.keymap.set("n", "<leader>?",
  function()
    require("which-key").show({ global = false })
  end,
  { desc = "Buffer Local Keymaps (which-key)" }
)

-- [Buffer]
vim.pack.add({ "https://github.com/akinsho/bufferline.nvim" })
require("bufferline").setup({
  options = {
    -- always_show_bufferline = false,
    -- themable = true,
    style_preset = require("bufferline").style_preset.no_italic,
    indicator = { style = "none" },
    -- separator_style = { "│", "│" },
    highlights = {
      separator = { fg = "#768390" },
    },
    -- Close
    close_command = function(bufnr)
      vim.cmd("bdelete " .. bufnr)
    end,
    right_mouse_command = function(bufnr)
      vim.cmd("bdelete " .. bufnr)
    end,
    -- LSP
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(_, _, diag)
      local ret = (diag.error and icons.lsp.Error .. diag.error .. " " or "")
          .. (diag.warning and icons.lsp.Warn .. diag.warning or "")
      return vim.trim(ret)
    end,
    -- Icon
    get_element_icon = function(opts)
      return icons.ft[opts.filetype] or icons.ft.fallback
    end,
    -- Offset
    offsets = {
      {
        filetype = "NetrwTreeListing",
        -- text = icons.basic.Vim .. " File Explorer",
        highlight = "Directory",
        text_align = "left",
        separator = true,
      }
    }
  }
})
-- Fix bufferline when restoring a session
vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
  callback = function()
    vim.schedule(function()
      pcall(nvim_bufferline)
    end)
  end,
})
vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "Toggle Pin" })
vim.keymap.set("n", "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", { desc = "Delete Non-Pinned Buffers" })

-- [Clipboard]
-- vim.pack.add({ "https://github.com/gbprod/yanky.nvim" })
-- -- Custom paste function
-- local function paste_from_unamed()
--   local lines = vim.split(vim.fn.getreg(""), "\n", { plain = true })
--   if #lines == 0 then
--     lines = { "" }
--   end
--   local rtype = vim.fn.getregtype(""):sub(1, 1)
--   return { lines, rtype }
-- end
-- -- Enable new clipboard define
-- vim.g.clipboard = {
--   name = "OSC 52",
--   copy = {
--     ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
--   },
--   paste = {
--     ["+"] = paste_from_unamed,
--     ["*"] = paste_from_unamed,
--   },
-- }
-- vim.api.nvim_create_autocmd("TextYankPost", {
--   callback = function()
--     local ev = vim.v.event
--     if ev.operator == "y" and ev.regname == "" then
--       vim.fn.setreg("", ev.regcontents, ev.regtype)
--     end
--   end,
-- })
-- require("yanky").setup({
--   ring = {
--     history_length = 3,
--   },
--   system_clipboard = {
--     sync_with_ring = true,
--   },
-- })
