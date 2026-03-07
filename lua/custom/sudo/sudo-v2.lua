local aug = vim.api.nvim_create_augroup('suda_simple', { clear = true })

-- 检查是否为 Windows
local function is_windows()
  return vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
end

-- 获取提权执行函数
-- 返回一个闭包，处理密码逻辑并执行命令
local function get_elevated_runner()
  if is_windows() and vim.fn.executable('gsudo') == 1 then
    return function(cmd_args, input_data)
      local full_cmd = vim.list_extend({ 'gsudo' }, cmd_args)
      local obj = vim.system(full_cmd, { stdin = input_data }):wait()
      return vim.split(obj.stdout or '', '\n'), obj.code
    end
  end

  if vim.fn.executable('sudo') == 1 then
    return function(cmd_args, input_data)
      -- 1. 先尝试非交互式提权 (如果 sudo 还在有效期内则不需要密码)
      local check = vim.system({ 'sudo', '-n', 'true' }):wait()

      local password = ''
      if check.code ~= 0 then
        -- 2. 如果需要密码，使用 inputsecret 弹出输入框
        password = vim.fn.inputsecret('Sudo Password: ')
        if password == '' then return nil, 1 end -- 用户取消
      end

      -- 使用 -S 参数从 stdin 读取密码
      local full_cmd = vim.list_extend({ 'sudo', '-S' }, cmd_args)
      local stdin_payload = password .. '\n'
      if input_data then stdin_payload = stdin_payload .. input_data end

      local obj = vim.system(full_cmd, { stdin = stdin_payload }):wait()
      return vim.split(obj.stdout or '', '\n'), obj.code
    end
  end
  return nil
end

local function real_file_buf(buf)
  if vim.bo[buf].buftype ~= '' then return false end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then return false end
  if name:match('^[%w%+%.%-]+://') then return false end
  return true
end

local function need_prompt(path)
  if vim.fn.getftype(path) == '' then return false end
  local r = vim.fn.filereadable(path) == 1
  local w = vim.fn.filewritable(path) == 1
  return (not r) or (not w)
end

local function set_write_cmd(buf, path, runner)
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    group = aug,
    buffer = buf,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local data = table.concat(lines, '\n') .. '\n'

      -- 使用 tee 写入文件，-a 是追加，这里不使用 -a
      local _, code = runner({ 'tee', path }, data)

      if code ~= 0 then
        vim.notify('[suda_simple] write failed', vim.log.levels.ERROR)
        return
      end
      vim.bo[buf].modified = false
      vim.notify('[suda_simple] File saved with admin', vim.log.levels.INFO)
    end,
  })
end

local function reopen_with_admin(buf, path, runner)
  local out, code = runner({ 'cat', path })

  if code ~= 0 then
    -- 如果用户按了 ESC 或者密码错误
    vim.notify('[suda_simple] reopen failed or cancelled', vim.log.levels.WARN)
    return
  end

  -- 清理末尾可能的空行（vim.split产生的）
  if out[#out] == '' then table.remove(out) end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
  vim.bo[buf].buftype = 'acwrite'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modified = false
  set_write_cmd(buf, path, runner)
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

    local runner = get_elevated_runner()
    if not runner then return end

    vim.schedule(function()
      local msg = ('Need admin to read/write:\n%s\n\nReopen with admin?'):format(vim.fn.fnamemodify(
      path, ':~'))
      if vim.fn.confirm(msg, '&Yes\n&No', 2) == 1 then
        reopen_with_admin(buf, path, runner)
      end
    end)
  end,
})
