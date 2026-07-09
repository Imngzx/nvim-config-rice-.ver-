local M = {}

local is_setup = false

M.config = {
  get_git_root = nil
}

function M.update_git_branch(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].buftype ~= '' or vim.b[bufnr].my_git_fetching then
    return
  end

  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == '' or filepath:match('^[%w%+%.%-]+://') then return end

  local dir
  if M.config.get_git_root then
    dir = M.config.get_git_root(filepath)
    if not dir then
      if vim.b[bufnr].my_git_branch then
        vim.b[bufnr].my_git_branch = nil
        vim.schedule(function() vim.cmd('redrawstatus!') end)
      end
      return
    end
  else
    dir = vim.fs.dirname(filepath)
  end

  vim.b[bufnr].my_git_fetching = true

  vim.system({ 'git', '-C', dir, 'rev-parse', '--abbrev-ref', 'HEAD' },
    { text = true, timeout = 1000 },
    function(obj)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.b[bufnr].my_git_fetching = false

          local new_branch = ''
          if obj.code == 0 and obj.stdout and obj.stdout ~= '' then
            new_branch = vim.trim(obj.stdout)
          end

          if vim.b[bufnr].my_git_branch ~= new_branch then
            vim.b[bufnr].my_git_branch = new_branch
            vim.cmd('redrawstatus!')
          end
        end
      end)
    end)
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  if is_setup then return end
  is_setup = true

  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'FocusGained', 'SessionLoadPost' }, {
    group = vim.api.nvim_create_augroup('LibsSharedGitFetcher', { clear = true }),
    callback = function(args)
      if args.event == 'SessionLoadPost' then
        vim.defer_fn(function()
          local bufs = vim.api.nvim_list_bufs()
          for i = 1, #bufs do
            if vim.api.nvim_buf_is_loaded(bufs[i]) then
              M.update_git_branch(bufs[i])
            end
          end
        end, 100)
      else
        M.update_git_branch(args.buf)
      end
    end,
  })
end

return M
