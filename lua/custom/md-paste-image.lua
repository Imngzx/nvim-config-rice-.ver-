local M = {
  opts = {
    img_dir = 'img/%:t:r',
    filetypes = { 'markdown', 'markdownx' },
    img_name = nil,
    drag_and_drop = true,
  },
}

local uv = vim.uv
local api = vim.api
local fn = vim.fn
local util = require('libs.utils')
local str_sub = string.sub
local str_gsub = string.gsub

local original_paste

-- Pre-computed filetype set for O(1) lookup
local enabled_ft = {}
for _, ft in ipairs(M.opts.filetypes) do enabled_ft[ft] = true end

local image_exts = {
  png = true, jpg = true, jpeg = true, gif = true,
  webp = true, bmp = true, tif = true, tiff = true, svg = true,
}

-- Cache for get_commands per OS
local commands_cache = {}

local function enabled()
  return enabled_ft[vim.bo.filetype]
end

local function get_os()
  if fn.has('win32') == 1 then
    return 'Windows'
  end

  if util.is_wsl() then
    return 'Wsl'
  end

  if util.is_mac() then
    return 'Darwin'
  end

  if util.is_penguin() then
    return 'Linux'
  end

  return nil
end

local function get_commands(os_name)
  if commands_cache[os_name] then
    return commands_cache[os_name]
  end

  local cmd
  if os_name == 'Windows' or os_name == 'Wsl' then
    local check = 'Get-Clipboard -Format Image'
    cmd = {
      check = 'powershell.exe "' .. check .. '"',
      save = 'powershell.exe "$content = ' .. check
        .. ";$content.Save('%s', 'png')\"",
    }
  elseif os_name == 'Darwin' then
    cmd = {
      check = 'pngpaste -b 2>&1',
      save = "pngpaste '%s'",
    }
  elseif os_name == 'Linux' then
    if vim.uv.os_getenv('XDG_SESSION_TYPE') == 'wayland' then
      cmd = {
        check = 'wl-paste --list-types',
        save = "wl-paste --no-newline --type image/png > '%s'",
      }
    else
      cmd = {
        check = 'xclip -selection clipboard -o -t TARGETS',
        save = "xclip -selection clipboard -t image/png -o > '%s'",
      }
    end
  end

  commands_cache[os_name] = cmd
  return cmd
end

-- Cache expand_dir per buffer
local expand_dir_cache = {}
local function expand_dir(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  if expand_dir_cache[bufnr] then
    return expand_dir_cache[bufnr]
  end

  local dir = fn.expand(M.opts.img_dir or '')
  local file = api.nvim_buf_get_name(bufnr)
  if file ~= '' then
    dir = str_gsub(dir, '%%(:[^/\\]+)', function(mod)
      return fn.fnamemodify(file, mod)
    end)
  end

  expand_dir_cache[bufnr] = dir
  return dir
end

-- Invalidate cache on buffer write
api.nvim_create_autocmd('BufWritePost', {
  pattern = '*',
  callback = function(args)
    expand_dir_cache[args.buf] = nil
  end,
})

local function image_path(name, bufnr)
  local dir = expand_dir(bufnr)

  if dir == '' then return name end

  fn.mkdir(dir, 'p')
  return dir .. '/' .. name
end

local function insert(path)
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local text = '![](' .. path .. ')'
  local line = api.nvim_get_current_line()

  api.nvim_set_current_line(
    str_sub(line, 1, col) .. text .. str_sub(line, col + 1)
  )

  api.nvim_win_set_cursor(0, {
    row,
    col + #text,
  })
end

-- Use vim.system for async clipboard check
local function check_clipboard_async(cmd, callback)
  vim.system({ 'sh', '-c', cmd }, { text = true }, function(obj)
    vim.schedule(function()
      callback(obj.code == 0 and obj.stdout or '')
    end)
  end)
end

function M.paste_img()
  if not enabled() then return end

  local os_name = get_os()
  local cmd = get_commands(os_name)
  if not cmd then
    vim.notify('clipboard-image: unsupported clipboard', vim.log.levels.ERROR)
    return
  end

  -- Async clipboard check
  check_clipboard_async(cmd.check, function(content)
    local has_image =
      os_name == 'Windows'
      or os_name == 'Wsl'
      or content:find('image/png', 1, true)
      or (
        os_name == 'Darwin'
        and str_sub(content, 1, 9) == 'iVBORw0KG'
      )

    if not has_image then
      vim.notify('clipboard-image: no image in clipboard', vim.log.levels.WARN)
      return
    end

    local name = tostring(
      M.opts.img_name or os.date('%Y-%m-%d-%H-%M-%S')
    ):gsub('%.png$', '') .. '.png'
    local bufnr = api.nvim_get_current_buf()
    local path = image_path(name, bufnr)

    -- Async save
    vim.system({ 'sh', '-c', string.format(cmd.save, path) }, { text = true }, function(obj)
      vim.schedule(function()
        if obj.code ~= 0 then
          vim.notify('clipboard-image: failed to save image\n' .. (obj.stderr or ''), vim.log.levels.ERROR)
          return
        end

        if fn.filereadable(path) == 0 then
          vim.notify('clipboard-image: image was not saved', vim.log.levels.ERROR)
          return
        end

        insert(path)
      end)
    end)
  end)
end

local function normalize(path)
  path = str_gsub(str_gsub(vim.trim(path), '^"(.*)"$', '%1'), "^'(.*)'$", '%1')

  if fn.has('win32') == 1 then
    local drive, rest = path:match('^/([a-zA-Z])/(.*)$')
    if drive then
      path = drive:upper() .. ':/' .. rest
    end
    path = str_gsub(path, '\\', '/')
  end

  return fn.fnamemodify(path, ':p')
end

function M.drop_img(raw_path)
  if not enabled() then
    return false
  end

  local path = normalize(raw_path)
  local ext = str_sub(fn.fnamemodify(path, ':e'), 1, 4):lower()
  if not image_exts[ext]
    or fn.filereadable(path) == 0 then
    return false
  end

  local bufnr = api.nvim_get_current_buf()
  local target = image_path(fn.fnamemodify(path, ':t'), bufnr)

  if fn.fnamemodify(path, ':p') ~= fn.fnamemodify(target, ':p') then
    local ok, err = uv.fs_copyfile(path, target)
    if not ok then
      vim.notify('clipboard-image: failed to copy image\n' .. tostring(err), vim.log.levels.ERROR)
      return true
    end
  end

  insert(target)
  return true
end

local function setup_drag()
  if original_paste then return end
  original_paste = vim.paste

  vim.paste = function(lines, phase)
    if phase == -1 and #lines == 1 and M.drop_img(lines[1]) then
      return
    end
    return original_paste(lines, phase)
  end
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', M.opts, opts or {})

  -- Rebuild enabled_ft if filetypes changed
  if opts and opts.filetypes then
    enabled_ft = {}
    for _, ft in ipairs(M.opts.filetypes) do enabled_ft[ft] = true end
  end

  if M.opts.drag_and_drop then
    setup_drag()
  end

  vim.keymap.set('n', '<leader>pi', M.paste_img, {
    silent = true,
    desc = 'Paste image',
  })
end

return M