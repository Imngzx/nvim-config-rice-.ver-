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

local function get_line_highlights(bufnr, lnum, line_content)
  local ft = vim.bo[bufnr].filetype
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, ft)
  if not ok or not parser then
    return { { line_content, 'Folded' } }
  end

  local query = vim.treesitter.query.get(parser:lang(), 'highlights')
  if not query then
    return { { line_content, 'Folded' } }
  end

  local tree = parser:parse()[1]
  local root = tree:root()
  local line_len = #line_content

  local hl_map = {}
  for id, node, _ in query:iter_captures(root, bufnr, lnum, lnum + 1) do
    local name = query.captures[id]
    local s_r, s_c, e_r, e_c = node:range()

    if s_r <= lnum and e_r >= lnum then
      local start_col = (s_r < lnum) and 0 or s_c
      local end_col = (e_r > lnum) and line_len or e_c

      for i = start_col, end_col - 1 do
        if i < line_len then
          hl_map[i] = '@' .. name
        end
      end
    end
  end

  local res = {}
  local start_idx = 1
  local curr_hl = hl_map[0]

  for i = 1, line_len do
    local hl = hl_map[i - 1]
    if hl ~= curr_hl then
      if i > start_idx then
        table.insert(res, { line_content:sub(start_idx, i - 1), curr_hl })
      end
      start_idx = i
      curr_hl = hl
    end
  end

  if start_idx <= line_len then
    table.insert(res, { line_content:sub(start_idx, line_len), curr_hl })
  end

  return #res > 0 and res or { { line_content, 'Folded' } }
end

local fold_cache = {}

vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('VibeFoldCacheClear', { clear = true }),
  callback = function(args)
    local prefix = args.buf .. '_'
    for k, _ in pairs(fold_cache) do
      if k:sub(1, #prefix) == prefix then
        fold_cache[k] = nil
      end
    end
  end
})

function _G.custom_foldtext()
  local start_lnum = vim.v.foldstart
  local end_lnum = vim.v.foldend
  local bufnr = vim.api.nvim_get_current_buf()

  local hash = bufnr .. '_' .. start_lnum .. '_' .. end_lnum
  if fold_cache[hash] then
    return fold_cache[hash]
  end

  local line = vim.fn.getline(start_lnum)

  line = line:gsub('\t', string.rep(' ', vim.bo.tabstop))

  local result = get_line_highlights(bufnr, start_lnum - 1, line)

  local end_line_text = vim.trim(vim.fn.getline(end_lnum))
  local folded_lines = end_lnum - start_lnum + 1

  table.insert(result, { ' ⋯ ', 'Comment' })

  if end_line_text ~= '' then
    table.insert(result, { end_line_text, 'Folded' })
  end

  table.insert(result, { '   ↙ [' .. folded_lines .. ' lines folded]', 'VibeFoldText' })

  fold_cache[hash] = result

  return result
end
