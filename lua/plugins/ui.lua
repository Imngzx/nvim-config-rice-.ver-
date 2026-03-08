local lazy = require('libs.lazy')

-- [Cursor]
-- lazy.load({
--   plugin = 'https://github.com/sphamba/smear-cursor.nvim',
--   event = { 'User', pattern = 'VeryLazy' },
--   setup = function()
--     require('smear_cursor').setup({
--       smear_between_buffers = true,
--     })
--   end
-- })
-- run after 100ms

-- [Icon]
vim.pack.add({ 'https://github.com/nvim-mini/mini.icons' })
require('mini.icons').setup()
require('mini.icons').mock_nvim_web_devicons()

lazy.load({
  plugin = 'https://github.com/bekaboo/dropbar.nvim',
  event = { 'User', pattern = 'VeryLazy' },
  setup = function()
    -- Dropbar 默认开箱即用，这里主要是绑定你需要的快捷键
    local dropbar_api = require('dropbar.api')

    vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
    vim.keymap.set('n', '[;', dropbar_api.goto_context_start,
      { desc = 'Go to start of current context' })
    vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
  end,
})

-- lazy.load({
--   plugin = 'https://github.com/b0o/incline.nvim',
--   event = 'BufReadPre',
--   setup = function()
--     local helpers = require('incline.helpers')
--
--     require('incline').setup({
--       ignore = {
--         floating_wins = false,
--         wintypes = function(winid, wintype)
--           -- 兼容你正在使用的 Snacks Zen 模式
--           local ok, snacks = pcall(require, 'snacks')
--           if ok and snacks.zen and snacks.zen.win and not snacks.zen.win.closed then
--             return winid ~= snacks.zen.win.win
--           end
--           return wintype ~= ''
--         end,
--       },
--       window = {
--         padding = 0,
--         margin = { horizontal = 1 },
--       },
--       hide = {
--         cursorline = true,
--       },
--       render = function(props)
--         local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
--         if filename == '' then
--           filename = '[No Name]'
--         end
--
--         -- 👇 1. 使用 mini.icons 获取图标和高亮组
--         local icon, hl = require('mini.icons').get('file', filename)
--
--         -- 👇 2. 将高亮组转换为 HEX 颜色代码，供 incline 渲染使用
--         local ft_color = '#ABB2BF' -- 默认灰色
--         if hl then
--           local hl_info = vim.api.nvim_get_hl(0, { name = hl, link = false })
--           if hl_info and hl_info.fg then
--             ft_color = string.format('#%06x', hl_info.fg)
--           end
--         end
--
--         local modified = vim.bo[props.buf].modified
--
--         return {
--           icon and { ' ', icon, ' ', guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or
--           '',
--           { ' ', guifg = ft_color },
--           { filename, gui = modified and 'bold' or 'none' },
--           modified and { ' [+]', guifg = '#ff9e64' } or '',
--           ' ',
--           -- 这里的背景色可以根据你的 catppuccin 主题调一下，比如 '#313244' (surface0)
--           guibg = '#44406e',
--         }
--       end,
--     })
--   end,
-- })
