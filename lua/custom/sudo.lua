local aug = vim.api.nvim_create_augroup('suda_simple', { clear = true })

local function is_windows()
  return vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
end

local function pick_elevate_cmd()
  -- Prefer gsudo on Windows if available, else sudo
  if is_windows() and vim.fn.executable('gsudo') == 1 then
    return { 'gsudo' }
  end
  if vim.fn.executable('sudo') == 1 then
    return { 'sudo', '-p', 'Password: ' }
  end
  return nil
end

local function real_file_buf(buf)
  if vim.bo[buf].buftype ~= '' then return false end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then return false end
  if name:match('^[%w%+%.%-]+://') then return false end
  local st = vim.uv.fs_stat(name)
  if st and st.type == 'directory' then return false end
  return true
end

local function need_prompt(path)
  -- don't prompt for new files
  if vim.fn.getftype(path) == '' then return false end
  local r = vim.fn.filereadable(path) == 1
  local w = vim.fn.filewritable(path) == 1
  return (not r) or (not w)
end

local function syslist(cmd, input)
  local out = vim.fn.systemlist(cmd, input)
  return out, vim.v.shell_error
end

local function set_write_cmd(buf, path, elev)
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    group = aug,
    buffer = buf,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local data = table.concat(lines, '\n') .. '\n'
      local cmd = vim.list_extend(vim.deepcopy(elev), { 'tee', path })
      local _, code = syslist(cmd, data)
      if code ~= 0 then
        vim.notify('[suda_simple] write failed', vim.log.levels.ERROR)
        return
      end
      vim.bo[buf].modified = false
    end,
  })
end

local function reopen_with_admin(buf, path, elev)
  local cmd = vim.list_extend(vim.deepcopy(elev), { 'cat', path })
  local out, code = syslist(cmd)
  if code ~= 0 then
    vim.notify('[suda_simple] reopen failed', vim.log.levels.ERROR)
    return
  end
  if #out == 0 then out = { '' } end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
  vim.bo[buf].buftype = 'acwrite'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modified = false
  set_write_cmd(buf, path, elev)
end

vim.api.nvim_create_autocmd('BufEnter', {
  group = aug,
  callback = function(args)
    local buf = args.buf
    if not real_file_buf(buf) then return end
    if vim.b[buf].suda_simple_checked then return end
    vim.b[buf].suda_simple_checked = true

    local path = vim.api.nvim_buf_get_name(buf)
    if not need_prompt(path) then return end

    local elev = pick_elevate_cmd()
    if not elev then return end

    vim.schedule(function()
      local msg = ('Need admin to read/write:\n%s\n\nReopen with admin?'):format(vim.fn.fnamemodify(
      path, ':~'))
      if vim.fn.confirm(msg, '&Yes\n&No', 2) == 1 then
        reopen_with_admin(buf, path, elev)
      end
    end)
  end,
})
