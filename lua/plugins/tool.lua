-- Clipboard
vim.pack.add({ "https://github.com/gbprod/yanky.nvim" })
-- Custom paste function
local function paste_from_unamed()
  local lines = vim.split(vim.fn.getreg(""), "\n", { plain = true })
  if #lines == 0 then
    lines = { "" }
  end
  local rtype = vim.fn.getregtype(""):sub(1, 1)
  return { lines, rtype }
end

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = paste_from_unamed,
    ["*"] = paste_from_unamed,
  },
}

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    local ev = vim.v.event
    if ev.operator == "y" and ev.regname == "" then
      vim.fn.setreg("", ev.regcontents, ev.regtype)
    end
  end,
})

require("yanky").setup({
  ring = {
    history_length = 3,
  },
  system_clipboard = {
    sync_with_ring = true,
  },
})
