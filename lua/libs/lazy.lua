-- Lightweight lazy loading implementation
local M = {}

--- Load the plugin(s) and run optional setup
local function do_load(plugins, setup)
  for _, plugin in ipairs(plugins) do
    vim.pack.add({ plugin })
  end
  if setup then setup() end
end

--- Create an autocmd that fires once and calls `do_load`
local function add_event_autocmd(events, plugins, setup)
  local event_name = events[1]
  local pattern = events[2] or events.pattern

  local opts = {
    once = true,
    callback = function() do_load(plugins, setup) end,
  }
  -- Add pattern for User events
  if event_name == 'User' and pattern then
    opts.pattern = pattern
    vim.api.nvim_create_autocmd(event_name, opts)
  else
    vim.api.nvim_create_autocmd(events, opts)
  end
end

--- Register a user command that loads the plugin on first use
local function add_cmd_triggers(cmds, plugins, setup)
  for _, cmd in ipairs(cmds) do
    vim.api.nvim_create_user_command(
      cmd,
      function(args)
        vim.api.nvim_del_user_command(cmd)
        do_load(plugins, setup)

        -- Re‑execute the original command with its arguments
        local cmd_string = cmd
        if args.args and args.args ~= '' then
          cmd_string = cmd_string .. ' ' .. args.args
        end
        if args.bang then cmd_string = cmd_string .. '!' end
        vim.cmd(cmd_string)
      end,
      { nargs = '*', bang = true, range = true, complete = 'file' }
    )
  end
end

--- Register a key‑map that loads the plugin on first press
local function add_key_triggers(keys, plugins, setup, restore_keys)
  for _, key_cfg in ipairs(keys) do
    local mode = key_cfg[1] or key_cfg.mode or 'n'
    local lhs = key_cfg[2] or key_cfg.lhs
    local rhs = key_cfg[3] or key_cfg.rhs
    local opts = key_cfg[4] or key_cfg.opts or {}

    if lhs then
      vim.keymap.set(mode, lhs, function()
        vim.keymap.del(mode, lhs)
        do_load(plugins, setup)

        if rhs then
          if type(rhs) == 'function' then
            rhs()
          elseif type(rhs) == 'string' then
            -- 👇 完美支持 <cmd>...<cr> 等字符串映射
            local k = vim.api.nvim_replace_termcodes(rhs, true, false, true)
            vim.api.nvim_feedkeys(k, 'm', false)
          end
          if restore_keys then
            vim.keymap.set(mode, lhs, rhs, opts)
          end
        else
          local k = vim.api.nvim_replace_termcodes(lhs, true, false, true)
          vim.api.nvim_feedkeys(k, 'i', false)
        end
      end, opts)
    end
  end
end

--- Autocmd for filetype triggers
local function add_ft_autocmd(fts, plugins, setup)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = fts,
    once = true,
    callback = function() do_load(plugins, setup) end,
  })
end

--- Public API
function M.load(config)
  local plugins = config.plugin
  if type(plugins) == 'string' then
    plugins = { plugins }
  elseif plugins == nil then
    plugins = {}
  end

  if config.event then
    local ev = type(config.event) == 'string' and { config.event } or config.event
    add_event_autocmd(ev, plugins, config.setup)
  end
  if config.cmd then
    local cmds = type(config.cmd) == 'string' and { config.cmd } or config.cmd
    add_cmd_triggers(cmds, plugins, config.setup)
  end
  if config.keys then
    add_key_triggers(config.keys, plugins, config.setup, config.restore_keys ~= false)
  end
  if config.ft then
    local fts = type(config.ft) == 'string' and { config.ft } or config.ft
    add_ft_autocmd(fts, plugins, config.setup)
  end
end

-- Trigger VeryLazy event after UI is ready
M.trigger_verylazy = function()
  -- 👇 修复 Headless 模式（如终端无UI跑脚本）时 VeryLazy 死寂的问题
  if #vim.api.nvim_list_uis() == 0 then
    vim.schedule(function()
      vim.api.nvim_exec_autocmds('User', { pattern = 'VeryLazy' })
    end)
    return
  end

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
