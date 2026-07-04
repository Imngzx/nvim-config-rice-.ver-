local M = {}

local api = vim.api
local uv = vim.uv
local fs = vim.fs

function M.new_card()
  vim.ui.input({ prompt = ' 󰎚 Card Title: ' }, function(title)
    if not title or title == '' then return end

    vim.schedule(function()
      local timestamp = os.date('%Y%m%d%H%M')
      local safe_title = title:gsub('%s+', '-'):gsub('[^%w%-一-龥]', ''):lower()
      local filename = timestamp .. '-' .. safe_title .. '.md'

      local buf_path = api.nvim_buf_get_name(0)
      local base_dir = buf_path ~= '' and fs.dirname(buf_path) or uv.cwd()
      local root = fs.root(0, { '.marksman.toml', '.git' }) or base_dir

      local target_dir = fs.normalize(root .. '/Cards')

      if not uv.fs_stat(target_dir) then
        vim.fn.mkdir(target_dir, 'p')
      end

      local filepath = target_dir .. '/' .. filename

      local lines = {
        '---',
        'title: ' .. title,
        'date: ' .. os.date('%Y-%m-%d %H:%M:%S'),
        'tags: []',
        '---',
        '',
        '# ' .. title,
        '',
        'Links: [[]]',
      }

      local bufnr = api.nvim_create_buf(true, false)

      api.nvim_buf_set_name(bufnr, filepath)
      api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      api.nvim_set_option_value('filetype', 'markdown', { buf = bufnr })

      api.nvim_set_current_buf(bufnr)

      api.nvim_win_set_cursor(0, { 9, 9 })
      vim.cmd('startinsert')
    end)
  end)
end

return M
