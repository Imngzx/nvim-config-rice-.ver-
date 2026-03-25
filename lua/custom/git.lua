-- toggle_stage.lua
local M = {}

M.config = {
  -- stage_action = require('snacks.picker').actions.git_stage,
  stage_action = nil,
  -- get_git_root = require('snacks.git').get_root
  get_git_root = nil
}

-- Returns a two‑character string such as " M", "M ", "??", etc.
local function get_file_status(git_root, rel_path)
  local out = vim.fn.systemlist({
    'git',
    '-C',
    git_root,
    'status',
    '--porcelain=v1',
    '--',
    rel_path,
  })
  if #out == 0 then return nil end
  return out[1]:sub(1, 2)
end

-- Helper: build the item table expected by Snacks.picker.git_stage -----
local function make_item(git_root, rel_path, status)
  return {
    cwd = git_root,
    status = status, -- e.g. " M" (unstaged) or "M " (staged)
    file = rel_path,
  }
end

--- Toggle the stage/unstage state of the file in the current buffer.
function M.toggle_stage()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == '' then
    vim.notify('Current buffer has no associated file', vim.log.levels.ERROR)
    return
  end

  local git_root = M.config.get_git_root(bufname)
  if not git_root then
    vim.notify('Not inside a Git repository', vim.log.levels.ERROR)
    return
  end

  local rel_path = vim.fn.fnamemodify(bufname, ':.') -- path relative to repo root
  local status = get_file_status(git_root, rel_path)
  if not status then
    vim.notify('File is not tracked by Git', vim.log.levels.ERROR)
    return
  end

  -- Minimal picker object that satisfies the interface expected by
  -- Snacks.picker.git_stage. It returns a single item and provides a
  -- refresh callback that simply informs the user.
  local picker = {
    selected = function(_, _)
      return { make_item(git_root, rel_path, status) }
    end,
    refresh = function()
      local action = status:sub(2, 2) == ' ' and 'unstaged' or 'staged'
      vim.notify(
        string.format('File %s %s', rel_path, action),
        vim.log.levels.INFO
      )
    end,
  }

  -- Execute the actual staging/unstaging logic.
  M.config.stage_action(picker)
end

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  -- Fill in sensible defaults if the user didn't provide them.
  if not M.config.stage_action then
    M.config.stage_action = require('snacks.picker').git_stage
  end
  if not M.config.get_git_root then
    M.config.get_git_root = require('snacks.git').get_root
  end

  vim.keymap.set('n', '<leader>ga', M.toggle_stage, { desc = 'Toggle git stage' })
end

return M
