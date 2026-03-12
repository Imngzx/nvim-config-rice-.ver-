local function augroup(name)
  return vim.api.nvim_create_augroup('lazyvim_' .. name, { clear = true })
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LspAttachFolding', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client:supports_method('textDocument/foldingRange') then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end
  end,
})

-- [Autocmd] 仅对文书类文件开启拼写检查
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('TextSpellCheck', { clear = true }),
  pattern = {
    'markdown',
    'text',
    'gitcommit',
    'plaintex',
    'typst' -- 如果你写 Typst 的话
  },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { 'en_us', 'ms' } -- 保持你的语言偏好
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('DisableAutoComment', { clear = true }),
  callback = function()
    vim.opt.formatoptions:remove({ 'c', 'r', 'o' })
  end,
})

-- [Autocmd] Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('HighlightOnYank', {}),
  callback = function() (vim.hl or vim.highlight).on_yank() end,
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
    -- 排除特殊 buffer（终端、浮动窗口等）
    if vim.bo[args.buf].buftype ~= '' then return end

    -- 使用 Nvim 0.10+ 原生 C API，性能极高且无 Lua 内存泄漏
    local root = vim.fs.root(args.buf, { '.git', 'Makefile', '.jj' })
    if root then
      -- 使用纯原生 API 替代 vim.fn.chdir，跳过 vimscript 转换层，速度拉满
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
