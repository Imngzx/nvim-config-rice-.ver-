local M = {}

function M.setup()
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'FocusGained' }, {
    group = vim.api.nvim_create_augroup('HeirlineGitBranch', { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      if vim.bo[bufnr].buftype ~= '' or vim.b[bufnr].my_git_fetching then return end
      local filepath = vim.api.nvim_buf_get_name(bufnr)
      if filepath == '' or filepath:match('^[%w%+%.%-]+://') then return end

      local dir = vim.fn.fnamemodify(filepath, ':h')
      vim.b[bufnr].my_git_fetching = true

      vim.system({ 'git', '-C', dir, 'rev-parse', '--abbrev-ref', 'HEAD' },
        { text = true, timeout = 1000 },
        function(obj)
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
              vim.b[bufnr].my_git_fetching = false
              local new_branch = (obj.code == 0 and obj.stdout) and vim.trim(obj.stdout) or ''
              if vim.b[bufnr].my_git_branch ~= new_branch then
                vim.b[bufnr].my_git_branch = new_branch
                vim.cmd('redrawstatus')
              end
            end
          end)
        end)
    end,
  })
end

return M
