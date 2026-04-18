-- Lightweight lazy loading implementation
local M = {}

M.build_hooks = {}

-- =====================================================================
-- 🛠️ 1: 底层 PackChanged 监听器 (保留精华：完美解决自动 Build)
-- =====================================================================
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('DIY_Lazy_Builder', { clear = true }),
  callback = function(args)
    local data = args.data
    if not data or data.kind ~= 'install' then return end

    local name = data.spec.name
    local build_task = M.build_hooks[name]
    if not build_task then return end

    local dir = data.spec.dir
    vim.notify('[Lazy] Building ' .. name .. '...', vim.log.levels.INFO)

    if type(build_task) == 'string' then
      local shell = require('libs.utils').is_windows() and 'cmd' or 'sh'
      local flag = require('libs.utils').is_windows() and '/c' or '-c'

      vim.system({ shell, flag, build_task }, { cwd = dir, text = true }, function(out)
        vim.schedule(function()
          if out.code == 0 then
            vim.notify('[Lazy] Build success: ' .. name, vim.log.levels.INFO)
          else
            vim.notify('[Lazy] Build failed: ' .. name .. '\n' .. (out.stderr or ''),
              vim.log.levels.ERROR)
          end
        end)
      end)
    elseif type(build_task) == 'function' then
      vim.schedule(function()
        local ok, err = pcall(build_task, dir)
        if ok then
          vim.notify('[Lazy] Build function executed: ' .. name, vim.log.levels.INFO)
        else
          vim.notify('[Lazy] Build failed: ' .. name .. '\n' .. tostring(err), vim.log.levels.ERROR)
        end
      end)
    end
  end,
})

-- =====================================================================
-- 核心加载器触发器 (去除了引起 Bug 的 args.buf 参数传递)
-- =====================================================================
local function add_event_autocmd(events, loader)
  local event_name = events[1]
  local pattern = events[2] or events.pattern

  local opts = {
    once = true,
    callback = function() loader() end,
  }
  if event_name == 'User' and pattern then
    opts.pattern = pattern
    vim.api.nvim_create_autocmd(event_name, opts)
  else
    vim.api.nvim_create_autocmd(events, opts)
  end
end

local function add_cmd_triggers(cmds, loader)
  for _, cmd in ipairs(cmds) do
    vim.api.nvim_create_user_command(
      cmd,
      function(args)
        vim.api.nvim_del_user_command(cmd)
        loader()

        local cmd_opts = { cmd = cmd, args = args.fargs, bang = args.bang }
        if args.range == 1 then
          cmd_opts.range = { args.line1 }
        elseif args.range == 2 then
          cmd_opts.range = { args.line1, args.line2 }
        elseif args.count and args.count >= 0 then
          cmd_opts.count = args.count
        end

        vim.cmd(cmd_opts)
      end,
      { nargs = '*', bang = true, range = true, complete = 'file' }
    )
  end
end

local function add_key_triggers(keys, loader, restore_keys)
  for _, key_cfg in ipairs(keys) do
    local mode = key_cfg[1] or key_cfg.mode or 'n'
    local lhs = key_cfg[2] or key_cfg.lhs
    local rhs = key_cfg[3] or key_cfg.rhs
    local opts = key_cfg[4] or key_cfg.opts or {}

    if lhs then
      vim.keymap.set(mode, lhs, function()
        vim.keymap.del(mode, lhs)
        loader()

        if rhs then
          if type(rhs) == 'function' then
            rhs()
          elseif type(rhs) == 'string' then
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

local function add_ft_autocmd(fts, loader)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = fts,
    once = true,
    callback = function() loader() end,
  })
end

--- Public API
function M.load(config)
  local plugins = config.plugin
  if type(plugins) == 'string' then plugins = { plugins } end
  plugins = plugins or {}

  if config.build then
    for _, plugin in ipairs(plugins) do
      ---@diagnostic disable-next-line: undefined-field
      local target_url = type(plugin) == 'string' and plugin or
        (plugin.src or plugin.url or plugin[1])

      ---@diagnostic disable-next-line: undefined-field
      local name = (type(plugin) == 'table' and plugin.name)
        or (target_url and vim.fn.fnamemodify(target_url, ':t'):gsub('%.git$', ''))

      if name then
        M.build_hooks[name] = config.build
      end
    end
  end

  local loaded = false
  local function load_now()
    if loaded then return end
    loaded = true

    if #plugins > 0 then
      vim.pack.add(plugins)
    end

    if config.setup then config.setup() end
  end

  if config.event then
    local ev = type(config.event) == 'string' and { config.event } or config.event
    add_event_autocmd(ev, load_now)
  end
  if config.cmd then
    local cmds = type(config.cmd) == 'string' and { config.cmd } or config.cmd
    add_cmd_triggers(cmds, load_now)
  end
  if config.keys then
    add_key_triggers(config.keys, load_now, config.restore_keys ~= false)
  end
  if config.ft then
    local fts = type(config.ft) == 'string' and { config.ft } or config.ft
    add_ft_autocmd(fts, load_now)
  end
end

M.trigger_verylazy = function()
  vim.api.nvim_create_autocmd('UIEnter', {
    once = true,
    callback = function()
      vim.schedule(function()
        vim.api.nvim_exec_autocmds('User', { pattern = 'VeryLazy' })
      end)
    end,
  })

  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
      if #vim.api.nvim_list_uis() == 0 then
        vim.schedule(function()
          vim.api.nvim_exec_autocmds('User', { pattern = 'VeryLazy' })
        end)
      end
    end
  })
end

return M
