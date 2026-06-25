-- this is for plugins
local M = {}

local is_setup = false

M.config = {
  get_git_root = nil
}

function M.update_git_branch(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].buftype ~= ''
    or vim.b[bufnr].my_git_fetching
    or vim.b[bufnr].my_git_not_repo then
    return
  end

  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == '' or filepath:match('^[%w%+%.%-]+://') then return end

  local dir
  if M.config.get_git_root then
    dir = M.config.get_git_root(filepath)
    if not dir then
      vim.b[bufnr].my_git_not_repo = true
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
          else
            vim.b[bufnr].my_git_not_repo = true
          end

          if vim.b[bufnr].my_git_branch ~= new_branch then
            vim.b[bufnr].my_git_branch = new_branch
            vim.api.nvim_command('redrawstatus')
          end
        end
      end)
    end)
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  if is_setup then return end
  is_setup = true

  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'FocusGained' }, {
    group = vim.api.nvim_create_augroup('LibsSharedGitFetcher', { clear = true }),
    callback = function(args)
      M.update_git_branch(args.buf)
    end,
  })
end

return M
