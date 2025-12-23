-- Lightweight lazy loading implementation
local M = {}

--- Load plugins on specified events
---@param events string|table Event name(s) or {event, pattern} for User events
---@param plugins string|table Plugin URL(s) or config
---@param callback function|nil Callback after loading
M.on_event = function(events, plugins, callback)
  if type(events) == 'string' then events = { events } end
  if type(plugins) == 'string' then plugins = { plugins } end

  -- Check if it's a User event with pattern
  local event_name = events[1]
  local pattern = events[2] or events.pattern

  local autocmd_opts = {
    once = true,
    callback = function()
      for _, plugin in ipairs(plugins) do
        vim.pack.add({ plugin })
      end
      if callback then callback() end
      return true
    end,
  }

  -- Add pattern for User events
  if event_name == 'User' and pattern then
    autocmd_opts.pattern = pattern
    vim.api.nvim_create_autocmd(event_name, autocmd_opts)
  else
    vim.api.nvim_create_autocmd(events, autocmd_opts)
  end
end

--- Load plugins on command execution
---@param cmds string|table Command name(s)
---@param plugins string|table Plugin URL(s) or config
---@param callback function|nil Callback after loading
M.on_cmd = function(cmds, plugins, callback)
  if type(cmds) == 'string' then cmds = { cmds } end
  if type(plugins) == 'string' then plugins = { plugins } end

  for _, cmd in ipairs(cmds) do
    vim.api.nvim_create_user_command(cmd, function(args)
      -- Delete temporary command
      vim.api.nvim_del_user_command(cmd)
      -- Load plugins
      for _, plugin in ipairs(plugins) do
        vim.pack.add({ plugin })
      end
      if callback then callback() end
      -- Re-execute command with original arguments
      local cmd_string = cmd
      if args.args and args.args ~= '' then
        cmd_string = cmd_string .. ' ' .. args.args
      end
      if args.bang then
        cmd_string = cmd_string .. '!'
      end
      vim.cmd(cmd_string)
    end, { nargs = '*', bang = true, range = true, complete = 'file' })
  end
end

--- Load plugins on keymap
---@param mode string|table Mode(s)
---@param lhs string Key mapping
---@param plugins string|table Plugin URL(s) or config
---@param callback function|nil Callback after loading
---@param rhs string|function|nil Final command to execute
---@param opts table|nil Keymap options
M.on_key = function(mode, lhs, plugins, callback, rhs, opts)
  if type(plugins) == 'string' then plugins = { plugins } end
  opts = opts or {}

  vim.keymap.set(mode, lhs, function()
    -- Delete temporary keymap
    vim.keymap.del(mode, lhs)
    -- Load plugins
    for _, plugin in ipairs(plugins) do
      vim.pack.add({ plugin })
    end
    if callback then callback() end
    -- Execute actual functionality
    if rhs then
      if type(rhs) == 'function' then
        rhs()
      else
        vim.cmd(rhs)
      end
    else
      -- Re-trigger the key
      local key = vim.api.nvim_replace_termcodes(lhs, true, false, true)
      vim.api.nvim_feedkeys(key, 'i', false)
    end
  end, opts)
end

--- Load plugins on filetype
---@param fts string|table Filetype(s)
---@param plugins string|table Plugin URL(s) or config
---@param callback function|nil Callback after loading
M.on_ft = function(fts, plugins, callback)
  if type(fts) == 'string' then fts = { fts } end
  if type(plugins) == 'string' then plugins = { plugins } end

  vim.api.nvim_create_autocmd('FileType', {
    pattern = fts,
    once = true,
    callback = function()
      for _, plugin in ipairs(plugins) do
        vim.pack.add({ plugin })
      end
      if callback then callback() end
      return true
    end,
  })
end

--- Multi-trigger loader:  supports multiple loading conditions
---@param config table Configuration with triggers and setup
---  config.plugin:  string|table - Plugin URL(s)
---  config.event: string|table|nil - Event trigger(s)
---  config.cmd: string|table|nil - Command trigger(s)
---  config.keys: table|nil - Key trigger(s) { { mode, lhs, rhs, opts } }
---  config.ft: string|table|nil - Filetype trigger(s)
---  config.setup: function|nil - Setup function after loading
M.load = function(config)
  local loaded = false
  local plugins = config.plugin
  if type(plugins) == 'string' then plugins = { plugins } end

  local function do_load()
    if loaded then return end
    loaded = true

    -- Load plugins
    for _, plugin in ipairs(plugins) do
      vim.pack.add({ plugin })
    end

    -- Run setup
    if config.setup then
      config.setup()
    end
  end

  -- Event triggers
  if config.event then
    local events = type(config.event) == 'string' and { config.event } or config.event
    vim.api.nvim_create_autocmd(events, {
      once = true,
      callback = function()
        do_load()
        return true
      end,
    })
  end

  -- Command triggers
  if config.cmd then
    local cmds = type(config.cmd) == 'string' and { config.cmd } or config.cmd
    for _, cmd in ipairs(cmds) do
      vim.api.nvim_create_user_command(cmd, function(args)
        vim.api.nvim_del_user_command(cmd)
        do_load()
        -- Re-execute command with original arguments
        local cmd_string = cmd
        if args.args and args.args ~= '' then
          cmd_string = cmd_string .. ' ' .. args.args
        end
        if args.bang then
          cmd_string = cmd_string .. '!'
        end
        vim.cmd(cmd_string)
      end, { nargs = '*', bang = true, range = true, complete = 'file' })
    end
  end

  -- Keymap triggers
  if config.keys then
    for _, key_config in ipairs(config.keys) do
      local mode = key_config[1] or key_config.mode or 'n'
      local lhs = key_config[2] or key_config.lhs
      local rhs = key_config[3] or key_config.rhs
      local opts = key_config[4] or key_config.opts or {}

      if lhs then
        vim.keymap.set(mode, lhs, function()
          vim.keymap.del(mode, lhs)
          do_load()
          if rhs then
            if type(rhs) == 'function' then
              rhs()
            else
              vim.cmd(rhs)
            end
          else
            local k = vim.api.nvim_replace_termcodes(lhs, true, false, true)
            vim.api.nvim_feedkeys(k, 'i', false)
          end
        end, opts)
      end
    end
  end

  -- Filetype triggers
  if config.ft then
    local fts = type(config.ft) == 'string' and { config.ft } or config.ft
    vim.api.nvim_create_autocmd('FileType', {
      pattern = fts,
      once = true,
      callback = function()
        do_load()
        return true
      end,
    })
  end
end

-- Trigger VeryLazy event after UI is ready
M.trigger_verylazy = function()
  vim.api.nvim_create_autocmd('UIEnter', {
    once = true,
    callback = function()
      vim.schedule(function()
        vim.api.nvim_exec_autocmds('User', { pattern = 'VeryLazy' })
      end)
    end,
  })
end

return M
