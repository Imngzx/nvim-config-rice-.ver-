-- 手搓版 纯视觉 Dropbar (面包屑导航)
-- 零性能损耗，调用内置 Treesitter 极速提取上下文，完美融合 mini.icons

local M = {}

-- 1. 将 Treesitter 的语法节点映射到 mini.icons 的 LSP 类型
local ts_type_map = {
  ['class'] = 'class',
  ['class_declaration'] = 'class',
  ['class_definition'] = 'class',
  ['struct'] = 'struct',
  ['struct_specifier'] = 'struct',
  ['enum'] = 'enum',
  ['enum_specifier'] = 'enum',
  ['interface_declaration'] = 'interface',
  ['function'] = 'function',
  ['function_declaration'] = 'function',
  ['function_definition'] = 'function',
  ['arrow_function'] = 'function',
  ['method'] = 'method',
  ['method_declaration'] = 'method',
  ['method_definition'] = 'method',
}

-- 辅助函数：提取语法节点中的纯文本
local function get_node_text(node, bufnr)
  local s_row, s_col, e_row, e_col = node:range()
  if s_row == e_row then
    local line = vim.api.nvim_buf_get_lines(bufnr, s_row, s_row + 1, false)[1]
    return line and string.sub(line, s_col + 1, e_col) or ''
  end
  return ''
end

-- 辅助函数：智能寻找函数/类的“名字”
local function get_node_name(node, bufnr)
  -- 优先找标记为 name 的字段
  for child, field in node:iter_children() do
    if field == 'name' then return get_node_text(child, bufnr) end
  end
  -- 备用方案：找第一个标识符
  for child in node:iter_children() do
    local type = child:type()
    if type == 'identifier' or type == 'property_identifier' or type == 'name' then
      return get_node_text(child, bufnr)
    end
  end
  return ''
end

-- 核心渲染逻辑
function M.update()
  local winid = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()

  -- 忽略非正常文件（比如终端、悬浮窗、侧边栏）
  if vim.bo[bufnr].buftype ~= '' then
    pcall(vim.api.nvim_set_option_value, 'winbar', '', { win = winid })
    return
  end

  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
  if filename == '' then return end

  -- 2. 获取文件图标 (利用 mini.icons)
  local ok, mini_icons = pcall(require, 'mini.icons')
  local f_icon, f_hl = '', 'Normal'
  if ok then f_icon, f_hl = mini_icons.get('file', filename) end

  -- 拼接第一层：文件层
  local str = string.format('%%#%s# %s %%*%%#WinBar# %s ', f_hl, f_icon, filename)

  -- 3. 利用 Treesitter 获取光标所在的代码上下文
  local context = {}
  local ok_ts, parser = pcall(vim.treesitter.get_parser, bufnr)
  if ok_ts and parser then
    local cursor = vim.api.nvim_win_get_cursor(winid)
    -- 获取光标所在的最小节点
    local root = parser:parse()[1]:root()
    local node = root:named_descendant_for_range(cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2])

    -- 向上追溯，收集所有父级类/函数
    while node do
      local type = node:type()
      local mapped_kind = ts_type_map[type]
      if mapped_kind then
        local name = get_node_name(node, bufnr)
        if name ~= '' then
          local s_icon, s_hl = '󰊕', 'Normal'
          if ok then s_icon, s_hl = mini_icons.get('lsp', mapped_kind) end
          -- 组装该层级的字符串 (图标带颜色，文字用普通 WinBar 颜色)
          table.insert(context, 1, string.format('%%#%s#%s %%*%%#WinBar#%s', s_hl, s_icon, name))
        end
      end
      node = node:parent()
    end
  end

  -- 4. 拼接所有面包屑
  local separator = '%#WinBarNC#  %*' -- 纯净的右箭头分隔符
  if #context > 0 then
    str = str .. separator .. table.concat(context, separator)
  end

  -- 赋值给当前窗口的 winbar
  pcall(vim.api.nvim_set_option_value, 'winbar', str, { win = winid })
end

function M.setup()
  -- 按需极速刷新，只有切换文件或光标移动时重新计算，几乎 0 耗时
  local group = vim.api.nvim_create_augroup('HandcraftedDropbar', { clear = true })
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'BufEnter' }, {
    group = group,
    callback = function() pcall(M.update) end
  })
end

return M
