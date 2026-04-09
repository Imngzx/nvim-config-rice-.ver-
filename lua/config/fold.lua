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
  group = vim.api.nvim_create_augroup('VibeFoldColor', { clear = true }),
  callback = set_fold_hl,
})
set_fold_hl()

function _G.custom_foldtext()
  local ok, result = pcall(vim.treesitter.foldtext)
  if not ok or type(result) ~= 'table' then
    result = { { vim.fn.getline(vim.v.foldstart), '' } }
  end

  local end_line_text = vim.trim(vim.fn.getline(vim.v.foldend))
  local folded_lines = vim.v.foldend - vim.v.foldstart + 1

  table.insert(result, { ' ⋯ ', 'Comment' })

  if end_line_text ~= '' then
    table.insert(result, { end_line_text, '' })
  end

  table.insert(result, { '   ↙ [' .. folded_lines .. ' lines folded]', 'VibeFoldText' })

  return result
end
