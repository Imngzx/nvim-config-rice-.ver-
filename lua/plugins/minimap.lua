-- lua/plugins/neominimap.lua
local resonance = require('resonance')

vim.g.neominimap = {
  auto_enable = true,
  layout = 'float',
  float = {
    minimap_width = 20,
    margin = {
      right = 0, ---@type integer
      top = 2, ---@type integer
      bottom = 15, ---@type integer
    },
    z_index = 1,
    window_border = 'rounded',
  },
  click = { enabled = true },
  diagnostic = { enabled = true, mode = 'line' },
  mini_diff = { enabled = true },
  git = { enabled = true, mode = 'sign' },
  treesitter = { enabled = true },
  notification_level = vim.log.levels.OFF,
}

resonance.load({
  'https://github.com/Isrothy/neominimap.nvim',

  keys = {
    { 'n', '<leader>nm', '<cmd>Neominimap Toggle<cr>', { desc = 'Toggle minimap' } },
    { 'n', '<leader>ns', '<cmd>Neominimap ToggleFocus<cr>', { desc = 'Focus minimap' } },
    { 'n', '<leader>no', '<cmd>Neominimap Enable<cr>', { desc = 'Open minimap' } },
    { 'n', '<leader>nc', '<cmd>Neominimap Disable<cr>', { desc = 'Close minimap' } },
    { 'n', '<leader>nr', '<cmd>Neominimap Refresh<cr>', { desc = 'Refresh minimap' } },
  },
  config = function()
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 36

    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      callback = function()
        -- 确保 Minimap 背景透明
        vim.api.nvim_set_hl(0, 'NeominimapBackground', { bg = 'NONE' })

        -- 扒取 Catppuccin 主题里的 Visual（选中颜色），大概是浅灰色/暗蓝色
        local ok, vis_hl = pcall(vim.api.nvim_get_hl, 0, { name = 'Visual', link = false })
        local block_color = (ok and vis_hl.bg) and string.format('#%06x', vis_hl.bg) or '#45475a'

        -- 强行把这个颜色塞给 Neominimap 的视口指示器！
        vim.api.nvim_set_hl(0, 'NeominimapCursorLine', { bg = block_color })
      end,
    })
    -- 强行触发一次
    vim.api.nvim_exec_autocmds('ColorScheme', {})
  end
})
