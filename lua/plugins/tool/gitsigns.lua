-- Git 状态展示
-- https://github.com/lewis6991/gitsigns.nvim
local icons = require("icons")
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = icons.lines.LeftVertical },
      change = { text = icons.lines.LeftVertical },
      delete = { text = icons.arrows.TriangleRight },
      topdelete = { text = icons.arrows.TriangleRight },
      changedelete = { text = icons.lines.LeftVertical },
      untracked = { text = icons.lines.LeftVertical },
    },
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

      -- stylua: ignore start
      map("n", "]h", gs.next_hunk, "Next Hunk")
      map("n", "[h", gs.prev_hunk, "Prev Hunk")
      map({ "n", "v" }, "<leader>gs", gs.stage_hunk, "Stage Hunk")
      map({ "n", "v" }, "<leader>gS", gs.undo_stage_hunk, "Undo Stage Hunk")
      map({ "n", "v" }, "<leader>gr", gs.reset_hunk, "Reset Hunk")
      map("n", "<leader>ga", gs.stage_buffer, "Add buffer")
      map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
      map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
      map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame")
      map("n", "<leader>gd", gs.diffthis, "Diff This")
      map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff This ~")
      map({ "o", "x" }, "sh", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
    end,
  },
}
