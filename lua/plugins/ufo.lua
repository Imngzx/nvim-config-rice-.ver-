-- lua/plugins/ufo.lua
local lazy = require('libs.lazy')

lazy.load({
  plugin = {
    'https://github.com/kevinhwang91/promise-async',
    'https://github.com/kevinhwang91/nvim-ufo',
  },
  event = { 'BufReadPost', 'BufNewFile' },
  keys = {
    { 'n', 'zR', function() require('ufo').openAllFolds() end, { desc = 'Open all folds' } },
    { 'n', 'zM', function() require('ufo').closeAllFolds() end, { desc = 'Close all folds' } },
    { 'n', 'zr', function() require('ufo').openFoldsExceptKinds() end, { desc = 'Fold less' } },
    { 'n', 'zm', function() require('ufo').closeFoldsWith() end, { desc = 'Fold more' } },
    { 'n', 'zp', function() require('ufo').peekFoldedLinesUnderCursor() end, { desc = 'Peek fold' } },
  },
  setup = function()
    local function set_fold_hl()
      local ok, color_lib = pcall(require, 'custom.color-list')
      if ok then
        vim.api.nvim_set_hl(0, 'VibeFoldText', {
          fg = color_lib.colors.toxic_matcha.hex,
          italic = true,
          bold = true
        })
      end
    end

    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('UfoFoldColor', { clear = true }),
      callback = set_fold_hl,
    })
    set_fold_hl()

    local handler = function(virtText, lnum, endLnum, width, truncate)
      local newVirtText = {}
      local foldedLines = endLnum - lnum
      local suffix = ('  ⋯  ↙ [%d lines folded]'):format(foldedLines)
      local sufWidth = vim.fn.strdisplaywidth(suffix)
      local targetWidth = width - sufWidth
      local curWidth = 0

      for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
        else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          local hlGroup = chunk[2]
          table.insert(newVirtText, { chunkText, hlGroup })
          chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if curWidth + chunkWidth < targetWidth then
            suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
          end
          break
        end
        curWidth = curWidth + chunkWidth
      end

      table.insert(newVirtText, { suffix, 'VibeFoldText' })
      return newVirtText
    end

    require('ufo').setup({
      open_fold_hl_timeout = 150,
      fold_virt_text_handler = handler,

      provider_selector = function(bufnr, filetype, buftype)
        if buftype == 'nofile' or buftype == 'terminal' or buftype == 'prompt' then
          return ''
        end

        if vim.b[bufnr].snacks_bigfile then
          return ''
        end

        return { 'treesitter', 'indent' }
      end,

      preview = {
        win_config = {
          border = 'rounded',
          winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder',
          winblend = 0
        },
        mappings = {
          scrollU = '<C-u>',
          scrollD = '<C-d>',
          jumpTop = '[',
          jumpBot = ']'
        }
      }
    })
  end
})
