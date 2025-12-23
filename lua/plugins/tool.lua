local icons = require("libs.icons")

-- [Key note]
vim.pack.add({ "https://github.com/folke/which-key.nvim" })
require("which-key").add({
  { "<leader>b", group = "Buffer" },
  { "<leader>c", group = "Code" },
  { "<leader>u", group = "UI" },
  { "<leader>s", group = "Session" },
  { "<leader>f", group = "File" },
})
vim.keymap.set("n", "<leader>?",
  function()
    require("which-key").show({ global = false })
  end,
  { desc = "Buffer Local Keymaps (which-key)" }
)

-- [File explorer]
vim.pack.add({ "https://github.com/nvim-mini/mini.files" })
require('mini.files').setup({
  mappings = {
    close = '<ESC>',
    synchronize = '<CR>',
  },
  windows = {
    -- Whether to show preview of file/directory under cursor
    preview = true,
    -- Width of focused window
    width_focus = 35,
    -- Width of preview window
    width_preview = 40,
  },
})
vim.keymap.set("n", "<leader>e", function(...)
  if not require('mini.files').close() then MiniFiles.open(...) end
end, { desc = "Toggle file explorer" })


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
