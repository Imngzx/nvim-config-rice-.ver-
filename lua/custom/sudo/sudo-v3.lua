local aug = vim.api.nvim_create_augroup('suda_simple', { clear = true })

local function is_windows()
  return vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
end

-- 改进的执行器：支持密码缓存（当前 session）和更稳健的输入处理
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
      -- 检查是否需要密码
      local check = vim.system({ 'sudo', '-n', 'true' }):wait()
      local password = ''
      if check.code ~= 0 then
        password = vim.fn.inputsecret('Sudo Password: ')
        if password == '' then return nil, 1 end
      end

      local full_cmd = vim.list_extend({ 'sudo', '-S' }, cmd_args)
      -- 组合密码和数据流
      local stdin_payload = password .. '\n'
      if input_data then stdin_payload = stdin_payload .. input_data end

      local obj = vim.system(full_cmd, { stdin = stdin_payload }):wait()
      return vim.split(obj.stdout or '', '\n'), obj.code
    end
  end
  return nil
end

local function real_file_buf(buf)
  local bt = vim.bo[buf].buftype
  if bt ~= '' and bt ~= 'acwrite' then return false end -- 允许已经是 acwrite 的再次检查
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then return false end
  if name:match('^[%w%+%.%-]+://') then return false end
  return true
end

local function need_prompt(path)
  local ftype = vim.fn.getftype(path)

  -- 情况 A: 文件不存在
  if ftype == '' then
    local dir = vim.fn.fnamemodify(path, ':h')
    -- filewritable 返回 2 表示文件夹可写，返回 0 表示不可写
    return vim.fn.filewritable(dir) ~= 2
  end

  -- 情况 B: 文件存在，但不可读或不可写
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

      -- 使用 sudo tee 写入文件
      local _, code = runner({ 'tee', path }, data)

      if code ~= 0 then
        vim.notify('[suda_simple] write failed', vim.log.levels.ERROR)
        return
      end

      vim.bo[buf].modified = false
      -- 写入成功后，如果是新文件，通知系统刷新其状态
      vim.fn.setfperm(path, 'rw-r--r--') -- 可选：设置默认权限
      vim.notify('[suda_simple] Saved with admin: ' .. path, vim.log.levels.INFO)
    end,
  })
end

local function enable_admin_mode(buf, path, runner)
  -- 如果文件存在，尝试用 sudo 读取内容
  if vim.fn.getftype(path) ~= '' then
    local out, code = runner({ 'cat', path })
    if code == 0 then
      if out[#out] == '' then table.remove(out) end
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
    else
      vim.notify('[suda_simple] Failed to read existing file', vim.log.levels.WARN)
    end
  end

  -- 核心：即使是新文件，也要切换到 acwrite 模式并拦截保存动作
  vim.bo[buf].buftype = 'acwrite'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modified = false
  set_write_cmd(buf, path, runner)
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile' }, {
  group = aug,
  callback = function(args)
    local buf = args.buf
    if not real_file_buf(buf) then return end
    if vim.b[buf].suda_simple_checked then return end

    local path = vim.api.nvim_buf_get_name(buf)
    if not need_prompt(path) then return end

    -- 标记已处理，防止循环
    vim.b[buf].suda_simple_checked = true

    local runner = get_elevated_runner()
    if not runner then return end

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then return end
      local display_path = vim.fn.fnamemodify(path, ':~')
      local msg = ('Permissions denied for:\n%s\n\nEnable Admin Write?'):format(display_path)

      if vim.fn.confirm(msg, '&Yes\n&No', 2) == 1 then
        enable_admin_mode(buf, path, runner)
      end
    end)
  end,
})
