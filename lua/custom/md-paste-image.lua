local util = require('libs.utils')

local M = {
  opts = {
    img_dir = 'img',
    filetypes = { 'markdown', 'markdownx' },
    img_name = nil,
    auto_paste = false,
  },
}

local function get_commands()
  if util.is_windows() then
    local check = 'Get-Clipboard -Format Image'

    return {
      check = 'powershell.exe "' .. check .. '"',
      paste = 'powershell.exe "$content = ' .. check
        .. ";$content.Save('%s', 'png')\"",
    }
  end

  local uname = io.popen('uname'):read()

  if util.is_penguin() then
    if vim.uv.os_getenv('XDG_SESSION_TYPE') == 'wayland' then
      return {
        check = 'wl-paste --list-types',
        paste = "wl-paste --no-newline --type image/png > '%s'",
      }
    end

    return {
      check = 'xclip -selection clipboard -o -t TARGETS',
      paste = "xclip -selection clipboard -t image/png -o > '%s'",
    }
  end

  if util.is_mac() then
    return {
      check = 'pngpaste -b 2>&1',
      paste = "pngpaste '%s'",
    }
  end

  return {}
end

function M.paste_img()
  if not vim.tbl_contains(M.opts.filetypes, vim.bo.filetype) then
    return
  end

  local commands = get_commands()

  if not commands.check then
    vim.notify('clipboard-image: unsupported clipboard', vim.log.levels.ERROR)
    return
  end

  local handle = io.popen(commands.check)

  if not handle then
    vim.notify('clipboard-image: failed to access clipboard', vim.log.levels.ERROR)
    return
  end

  local content = handle:read('*a')
  handle:close()

  local has_image = vim.fn.has('win32') == 1
    or content:find('image/png', 1, true)
    or (
      vim.fn.has('mac') == 1
      and content:sub(1, 9) == 'iVBORw0KG'
    )

  if not has_image then
    vim.notify('There is no image data in clipboard', vim.log.levels.ERROR)
    return
  end

  local img_name = M.opts.img_name or os.date('%Y-%m-%d-%H-%M-%S')
  local dir = vim.fn.expand(M.opts.img_dir)
  local path = dir == '' and img_name .. '.png' or dir .. '/' .. img_name .. '.png'

  vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
  os.execute(string.format(commands.paste, path))

  local cursor = vim.api.nvim_win_get_cursor(0)
  local text = string.format('![](%s)', path)
  local line = vim.api.nvim_get_current_line()

  vim.api.nvim_set_current_line(
    line:sub(1, cursor[2]) .. text .. line:sub(cursor[2] + 1)
  )

  vim.api.nvim_win_set_cursor(0, {
    cursor[1],
    cursor[2] + #text,
  })
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', M.opts, opts or {})

  if M.opts.auto_paste then
    vim.api.nvim_create_autocmd('FileType', {
      pattern = M.opts.filetypes,
      callback = function(event)
        vim.keymap.set('n', 'p', M.paste_img, {
          buffer = event.buf,
          silent = true,
        })
      end,
    })
  else
    vim.keymap.set('n', '<leader>pi', M.paste_img, {
      silent = true,
    })
  end
end

return M
