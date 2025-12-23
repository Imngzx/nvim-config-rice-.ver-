local icons = require('libs.icons')

-- [Key note]
vim.pack.add({ 'https://github.com/folke/which-key.nvim' })
require('which-key').add({
  { '<leader>b', group = 'Buffer' },
  { '<leader>c', group = 'Code' },
  { '<leader>f', group = 'File' },
  { '<leader>g', group = 'Git' },
  { '<leader>q', group = 'Quit' },
  { '<leader>s', group = 'Session' },
  { '<leader>u', group = 'UI' },
})
vim.keymap.set(
  'n',
  '<leader>?',
  function() require('which-key').show({ global = false }) end,
  { desc = 'which-key local keymap' }
)

-- [File explorer]
vim.pack.add({ 'https://github.com/nvim-mini/mini.files' })
local MiniFiles = require('mini.files')
-- Hide dotfiles
local hide = true
---@diagnostic disable-next-line: unused-local
local filter_show = function(fs_entry) return true end
local filter_hide = function(fs_entry)
  local name = fs_entry.name or ''
  if vim.startswith(name, '.') then return false end
  if name:lower() == 'node_modules' then return false end
  return true
end
local get_filter = function() return hide and filter_hide or filter_show end
MiniFiles.setup({
  mappings = {
    close = '<ESC>',
    synchronize = '<CR>',
  },
  content = {
    filter = get_filter(),
    prefix = function(fs_entry)
      if fs_entry.fs_type == 'directory' then
        -- NOTE: it is usually a good idea to use icon followed by space
        return icons.basic.directory .. ' ', 'MiniFilesDirectory'
      end
      return (icons.get_icon_by_name(fs_entry.name) or icons.basic.file) .. ' ', 'MiniFilesFile'
    end,
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
vim.keymap.set('n', '<leader>e', function(...)
  if not MiniFiles.close() then MiniFiles.open(...) end
end, { desc = 'Toggle file explorer' })
local toggle_dotfiles = function()
  hide = not hide
  MiniFiles.refresh({ content = { filter = get_filter() } })
end
vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    -- Tweak left-hand side of mapping to your liking
    vim.keymap.set('n', '.', toggle_dotfiles, { buffer = args.data.buf_id })
  end,
})

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
