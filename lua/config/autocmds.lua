local api = vim.api
local create_autocmd = api.nvim_create_autocmd
local create_augroup = api.nvim_create_augroup
local schedule = vim.schedule
local cmd = vim.cmd

local function augroup(name)
  return create_augroup('lazyvim_' .. name, { clear = true })
end

-- [Autocmd] 仅对文书类文件开启拼写检查
create_autocmd('FileType', {
  group = create_augroup('TextSpellCheck', { clear = true }),
  pattern = { 'markdown', 'text', 'gitcommit', 'plaintex', 'typst' },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { 'en_us', 'ms', 'cjk' }
  end,
})

-- no commenting on next line when o or O in normal mode
create_autocmd('FileType', {
  group = create_augroup('DisableAutoComment', { clear = true }),
  pattern = '*',
  callback = function()
    vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
  end,
})

-- [Autocmd] Highlight on yank
create_autocmd('TextYankPost', {
  group = create_augroup('HighlightOnYank', { clear = true }),
  callback = function() vim.hl.hl_op() end,
  desc = 'Highlight yanked text',
})

-- [Autocmd] Highlight on put (paste)
create_autocmd('TextPutPost', {
  group = create_augroup('HighlightOnPut', { clear = true }),
  callback = function() vim.hl.hl_op() end,
  desc = 'Highlight pasted text',
})

-- uses csvview plugin as soon as opening a csv file
create_autocmd('BufReadPost', {
  group = create_augroup('CsvViewAutoEnable', { clear = true }),
  pattern = '*.csv',
  callback = function()
    cmd([[CsvViewEnable delimiter=, display_mode=border header_lnum=1]])
  end,
})

-- [Autocmd] Change EOL format to unix on save
create_autocmd('BufWritePre', {
  group = create_augroup('WriteWithLF', { clear = true }),
  pattern = '*',
  callback = function(args)
    local bo = vim.bo[args.buf]
    if bo.readonly or bo.buftype ~= '' or bo.binary then return end
    bo.fileformat = 'unix'
  end,
})

-- [Autocmd] Auto set root
create_autocmd('BufEnter', {
  group = create_augroup('AutoSetRoot', { clear = true }),
  callback = function(args)
    if vim.g.SessionLoad or vim.bo[args.buf].buftype ~= '' then return end
    local root = vim.fs.root(args.buf, { '.git', 'Makefile', '.jj' })
    if root then api.nvim_set_current_dir(root) end
  end,
  desc = 'Find root and change current directory',
})

-- close some filetypes with <q>
create_autocmd('FileType', {
  group = augroup('close_with_q'),
  pattern = {
    'PlenaryTestPopup', 'checkhealth', 'dap-float', 'dbout', 'gitsigns-blame',
    'grug-far', 'help', 'lspinfo', 'neotest-output', 'neotest-output-panel',
    'neotest-summary', 'notify', 'qf', 'spectre_panel', 'startuptime',
    'tsplayground', 'msg', 'pager', 'dialog',
  },
  callback = function(event)
    local buf = event.buf
    vim.bo[buf].buflisted = false
    schedule(function()
      if not api.nvim_buf_is_valid(buf) then return end
      vim.keymap.set('n', 'q', function()
        cmd('close')
        pcall(api.nvim_buf_delete, buf, { force = true })
      end, { buf = buf, silent = true, desc = 'Quit buffer' })
    end)
  end,
})
