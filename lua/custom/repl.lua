local M = {}
local LOG_TITLE = 'VibeRepl'

local api = vim.api
local pcall, xpcall, load, type, select = pcall, xpcall, load, type, select
local setmetatable, setfenv = setmetatable, setfenv
local table_concat = table.concat
local debug_traceback = debug.traceback
local nvim_buf_get_text = api.nvim_buf_get_text
local nvim_buf_set_lines = api.nvim_buf_set_lines
local nvim_buf_get_mark = api.nvim_buf_get_mark
local nvim_get_current_buf = api.nvim_get_current_buf
local nvim_feedkeys = api.nvim_feedkeys
local nvim_replace_termcodes = api.nvim_replace_termcodes
local nvim_get_mode = api.nvim_get_mode
local schedule = vim.schedule
local inspect = vim.inspect

local CurrCtx = nil

local function new_env()
  return setmetatable({}, { __index = _G })
end

local function ensure_ctx()
  if not CurrCtx then CurrCtx = { env = new_env() } end
  return CurrCtx
end

function M.reset_current_ctx()
  CurrCtx = { env = new_env() }
end

local function repl_impl(lines)
  local out = {}
  local o_idx = 0

  local function append_out(str)
    o_idx = o_idx + 1
    out[o_idx] = str
  end

  local function fast_append_multiline(str)
    if not str then return end
    for s in (str .. '\n'):gmatch('(.-)\n') do
      o_idx = o_idx + 1
      out[o_idx] = s
    end
    if str:sub(-1) ~= '\n' then
      out[o_idx] = nil
      o_idx = o_idx - 1
    end
  end

  local function on_error(err)
    append_out('[ERROR]')
    if err then fast_append_multiline(err) end
    fast_append_multiline(debug_traceback())
  end

  local function on_print(...)
    local n = select('#', ...)
    local parts = {}
    for i = 1, n do
      local v = select(i, ...)
      parts[i] = type(v) == 'string' and v or inspect(v)
    end
    fast_append_multiline(table_concat(parts, ' '))
  end

  local source_code = table_concat(lines, '\n')
  local chunk, err = load(source_code, 'main@repl')

  if not chunk then
    on_error(err)
    return out
  end

  local env = ensure_ctx().env
  setfenv(chunk, env)
  env.print = on_print

  local results = { xpcall(chunk, on_error) }
  local ok = results[1]

  if ok then
    local res_count = #results
    if res_count > 1 then
      local ret_str = '=> ' .. inspect(results[2])
      fast_append_multiline(ret_str)

      for i = 3, res_count do
        append_out(',')
        fast_append_multiline(inspect(results[i]))
      end
    end
  end

  return out
end

local function get_lines(bufnr, from, to)
  local ok, ret = pcall(nvim_buf_get_text, bufnr, from[1], from[2], to[1], to[2], {})
  if not ok then
    vim.notify(
      string.format('Cannot get text of buffer %d, [%d:%d]-[%d:%d] because `%s`', bufnr, from[1],
        from[2], to[1], to[2], ret),
      vim.log.levels.ERROR,
      { title = LOG_TITLE }
    )
    return nil
  end
  return ret
end

function M.exec(bufnr, from, to)
  local lines = get_lines(bufnr, from, to)
  if not lines or #lines == 0 then return end
  local out = repl_impl(lines)
  if #out > 0 then
    local line_to_insert = to[1]
    nvim_buf_set_lines(bufnr, line_to_insert + 1, line_to_insert + 1, false, out)
  end
end

function M.eval(bufnr, from, to)
  local lines = get_lines(bufnr, from, to)
  if not lines or #lines == 0 then return end
  lines[#lines] = 'return ' .. lines[#lines]
  local out = repl_impl(lines)
  if #out > 0 then
    local line_to_insert = to[1]
    nvim_buf_set_lines(bufnr, line_to_insert + 1, line_to_insert + 1, false, out)
  end
end

local function change_mode(mode_key)
  nvim_feedkeys(nvim_replace_termcodes(mode_key, true, false, true), 'n', false)
end

local function exec_wrapper(fn)
  local buf = nvim_get_current_buf()
  local from = nvim_buf_get_mark(buf, '<')
  local to = nvim_buf_get_mark(buf, '>')

  from[1] = from[1] - 1
  to[1] = to[1] - 1
  to[2] = to[2] + 1

  fn(buf, from, to)
end

local function visual_wrapper(fn)
  local mode = nvim_get_mode().mode
  if mode ~= 'v' and mode ~= 'V' and mode ~= '\22' then
    vim.notify('Unsupported mode: start repl on modes `v`, `V` or `C-v`', vim.log.levels.ERROR,
      { title = LOG_TITLE })
    return
  end

  change_mode('<Esc>')
  schedule(function() exec_wrapper(fn) end)
end

function M.setup()
  local map = vim.keymap.set

  api.nvim_create_user_command('ReplExec', function() exec_wrapper(M.exec) end, { range = true })
  api.nvim_create_user_command('ReplEval', function() exec_wrapper(M.eval) end, { range = true })

  map('v', '<leader>rr', function() visual_wrapper(M.exec) end,
    { silent = true, desc = 'Exec selected code' })
  map('v', '<leader>re', function() visual_wrapper(M.eval) end,
    { silent = true, desc = 'Eval selected code' })
end

return M
