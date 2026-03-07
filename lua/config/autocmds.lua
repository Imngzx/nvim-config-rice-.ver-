local function augroup(name)
  return vim.api.nvim_create_augroup('lazyvim_' .. name, { clear = true })
end

-- [Autocmd] Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('HighlightOnYank', {}),
  callback = function() (vim.hl or vim.highlight).on_yank() end,
  desc = 'Highlight yanked text',
})

vim.api.nvim_create_autocmd('BufReadPost', {
  pattern = '*.csv',
  callback = function()
    vim.cmd([[CsvViewToggle delimiter=, display_mode=border header_lnum=1]])
  end,
})

-- [Autocmd] Change EOL format to unix on save
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('WriteWithLF', {}),
  pattern = '*',
  callback = function()
    if vim.bo.readonly or vim.bo.buftype ~= '' then return end
    vim.bo.fileformat = 'unix'
    vim.cmd([[ %s/\r\+$//e ]])
  end,
})

-- [Autocmd] Auto set root
-- https://github.com/nvim-mini/mini.misc/blob/main/lua/mini/misc.lua
local H = {}
H.names = { '.git', 'Makefile', '.jj' }
H.fallback = function() return nil end
H.root_cache = {}
-- Disable conflicting option
vim.o.autochdir = false

local find_root = function(buf_id, names, fallback)
  buf_id = buf_id or 0
  names = names or { '.git', 'Makefile' }
  fallback = fallback or function() return nil end

  -- Compute directory to start search from. NOTEs on why not using file path:
  -- - This has better performance because `vim.fs.find()` is called less.
  -- - *Needs* to be a directory for callable `names` to work.
  -- - Later search is done including initial `path` if directory, so this
  --   should work for detecting buffer directory as root.
  local path = vim.api.nvim_buf_get_name(buf_id)
  if path == '' then return end
  local dir_path = vim.fs.dirname(path)

  -- Try using cache
  local res = H.root_cache[dir_path]
  if res ~= nil then return res end

  -- Find root
  local root_file = vim.fs.find(names, { path = dir_path, upward = true })[1]
  if root_file ~= nil then
    res = vim.fs.dirname(root_file)
  else
    res = fallback(path)
  end

  -- Use absolute path to an existing directory
  if type(res) ~= 'string' then return end
  res = vim.fs.normalize(vim.fn.fnamemodify(res, ':p'))
  if vim.fn.isdirectory(res) == 0 then return end

  -- Cache result per directory path
  H.root_cache[dir_path] = res

  return res
end

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('AutoSetRoot', {}),
  nested = true,
  callback = vim.schedule_wrap(function(data)
    if data.buf ~= vim.api.nvim_get_current_buf() then return end
    local root = find_root(data.buf, H.names, H.fallback)
    if root == nil then return end
    vim.fn.chdir(root)
  end),
  desc = 'Find root and change current directory',
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
  group = augroup('close_with_q'),
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dap-float',
    'dbout',
    'gitsigns-blame',
    'grug-far',
    'help',
    'lspinfo',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd('close')
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})
