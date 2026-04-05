local function augroup(name)
  return vim.api.nvim_create_augroup('lazyvim_' .. name, { clear = true })
end

-- [Autocmd] 仅对文书类文件开启拼写检查
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('TextSpellCheck', { clear = true }),
  pattern = {
    'markdown',
    'text',
    'gitcommit',
    'plaintex',
    'typst'
  },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { 'en_us', 'ms', 'cjk' }
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('DisableAutoComment', { clear = true }),
  callback = function()
    ---@diagnostic disable-next-line: undefined-field
    vim.opt.formatoptions:remove({ 'c', 'r', 'o' })
  end,
})

-- [Autocmd] Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('HighlightOnYank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
  desc = 'Highlight yanked text',
})

vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('CsvViewAutoEnable', { clear = true }),
  pattern = '*.csv',
  callback = function()
    -- 👇 将 Toggle 改为 Enable
    vim.cmd([[CsvViewEnable delimiter=, display_mode=border header_lnum=1]])
  end,
})

-- [Autocmd] Change EOL format to unix on save
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('WriteWithLF', { clear = true }),
  pattern = '*',
  callback = function(args)
    if vim.bo[args.buf].readonly or vim.bo[args.buf].buftype ~= '' or vim.bo[args.buf].binary then return end
    -- 只设置格式，Neovim 保存时会自动以 \n 写入，无需破坏性正则操作
    vim.bo[args.buf].fileformat = 'unix'
  end,
})

-- [Autocmd] Auto set root
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('AutoSetRoot', { clear = true }),
  callback = function(args)
    if vim.g.SessionLoad then return end
    if vim.bo[args.buf].buftype ~= '' then return end

    local root = vim.fs.root(args.buf, { '.git', 'Makefile', '.jj' })
    if root then
      vim.api.nvim_set_current_dir(root)
    end
  end,
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
    'msg',
    'pager',
    'dialog',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd('close')
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buf = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})
