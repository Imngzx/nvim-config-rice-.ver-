local api = vim.api
local o = vim.o
local opt = vim.opt
local create_autocmd = api.nvim_create_autocmd
local create_augroup = api.nvim_create_augroup
local schedule = vim.schedule
local cmd = vim.cmd
local ui_group = create_augroup('AutoUIVisibility', { clear = true })
local vim_local = vim.opt_local
local map = vim.keymap.set

local function augroup(name)
  return create_augroup('lazyvim_' .. name, { clear = true })
end

-- [Autocmd] 仅对文书类文件开启拼写检查
create_autocmd('FileType', {
  group = create_augroup('TextSpellCheck', { clear = true }),
  pattern = { 'markdown', 'text', 'gitcommit', 'plaintex', 'typst' },
  callback = function()
    vim_local.spell = true
    vim_local.spelllang = { 'en_us', 'ms', 'cjk' }
  end,
})

-- no commenting on next line when o or O in normal mode
create_autocmd('FileType', {
  group = create_augroup('DisableAutoComment', { clear = true }),
  pattern = '*',
  callback = function()
    vim_local.formatoptions:remove({ 'c', 'r', 'o' })
  end,
})

-- [Autocmd] Highlight on yank and paste
create_autocmd({ 'TextYankPost', 'TextPutPost' }, {
  group = create_augroup('HighlightOnYankAndPaste', { clear = true }),
  callback = function() vim.hl.hl_op() end,
  desc = 'Highlight text when yank and paste',
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
      map('n', 'q', function()
        cmd('close')
        pcall(api.nvim_buf_delete, buf, { force = true })
      end, { buf = buf, silent = true, desc = 'Quit buffer' })
    end)
  end,
})

create_autocmd({ 'BufEnter', 'BufAdd', 'BufDelete' }, {
  group = ui_group,
  callback = function()
    local has_real_file = false
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
        local ft = vim.bo[buf].filetype
        local bt = vim.bo[buf].buftype
        local name = vim.api.nvim_buf_get_name(buf)

        if ft ~= 'snacks_dashboard' and not ft:match('^snacks_picker') then
          if name ~= '' or vim.bo[buf].modified or bt == 'terminal' then
            has_real_file = true
            break
          end
        end
      end
    end

    if has_real_file then
      if o.showtabline ~= 2 then opt.showtabline = 2 end
      if o.laststatus ~= 3 then opt.laststatus = 3 end
    else
      if o.showtabline ~= 0 then opt.showtabline = 1 end
      if o.laststatus ~= 0 then opt.laststatus = 0 end
    end
  end,
})
