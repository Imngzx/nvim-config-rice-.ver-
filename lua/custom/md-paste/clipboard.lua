local M = {}
local cf_html = require('custom.md-paste.cf_html')
local utils = require('libs.utils')

local windows_html_command = {
  'powershell.exe',
  '-NoProfile',
  '-NonInteractive',
  '-STA',
  '-Command',
  table.concat({
    [[Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class MdPasteClipboard {
  [DllImport("user32.dll", SetLastError=true)] static extern bool OpenClipboard(IntPtr owner);
  [DllImport("user32.dll", SetLastError=true)] static extern bool CloseClipboard();
  [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] static extern uint RegisterClipboardFormat(string name);
  [DllImport("user32.dll", SetLastError=true)] static extern IntPtr GetClipboardData(uint format);
  [DllImport("kernel32.dll", SetLastError=true)] static extern IntPtr GlobalLock(IntPtr memory);
  [DllImport("kernel32.dll", SetLastError=true)] static extern bool GlobalUnlock(IntPtr memory);
  [DllImport("kernel32.dll", SetLastError=true)] static extern UIntPtr GlobalSize(IntPtr memory);
  public static byte[] GetHtml() {
    uint format = RegisterClipboardFormat("HTML Format");
    if (format == 0 || !OpenClipboard(IntPtr.Zero)) return null;
    try {
      IntPtr handle = GetClipboardData(format);
      if (handle == IntPtr.Zero) return null;
      IntPtr pointer = GlobalLock(handle);
      if (pointer == IntPtr.Zero) return null;
      try {
        int size = (int)GlobalSize(handle);
        if (size <= 0) return null;
        byte[] bytes = new byte[size];
        Marshal.Copy(pointer, bytes, 0, size);
        if (bytes.Length > 0 && bytes[bytes.Length - 1] == 0) Array.Resize(ref bytes, bytes.Length - 1);
        return bytes;
      } finally {
        GlobalUnlock(handle);
      }
    } finally {
      CloseClipboard();
    }
  }
}
'@;]],
    '$bytes = [MdPasteClipboard]::GetHtml();',
    'if ($bytes) { $stdout = [Console]::OpenStandardOutput(); $stdout.Write($bytes, 0, $bytes.Length) };',
  }, ' '),
}

-- OS detection using jit.os and utils
local function get_os()
  if jit.os == 'Windows' then
    return 'Windows'
  end

  if utils.is_wsl() then
    return 'Wsl'
  end

  if jit.os == 'OSX' then
    return 'Darwin'
  end

  if jit.os == 'Linux' then
    return 'Linux'
  end

  return nil
end

local function get_image_commands(os_name)
  if os_name == 'Windows' or os_name == 'Wsl' then
    local check = table.concat({
      '$image = Get-Clipboard -Format Image -ErrorAction SilentlyContinue',
      "if ($null -eq $image) { exit 1 }",
      "'image/png'",
    }, '; ')

    return {
      check = { 'powershell.exe', '-NoProfile', '-Command', check },
      save = function(path)
        local escaped_path = path:gsub("'", "''")

        return {
          'powershell.exe',
          '-NoProfile',
          '-Command',
          "$content = Get-Clipboard -Format Image -ErrorAction Stop; "
            .. "$content.Save('" .. escaped_path .. "', 'png')",
        }
      end,
    }
  end

  if os_name == 'Darwin' then
    return {
      check = 'pngpaste -b 2>&1',
      save = "pngpaste '%s'",
    }
  end

  if os_name == 'Linux' then
    if vim.env.XDG_SESSION_TYPE == 'wayland' then
      return {
        check = 'wl-paste --list-types',
        save = "wl-paste --no-newline --type image/png > '%s'",
      }
    end

    return {
      check = 'xclip -selection clipboard -o -t TARGETS',
      save = "xclip -selection clipboard -t image/png -o > '%s'",
    }
  end

  return nil
end

local function get_html_command(os_name)
  if os_name == 'Darwin' then
    return 'pbpaste -Prefer html'
  end

  if os_name == 'Linux' then
    if vim.env.XDG_SESSION_TYPE == 'wayland' then
      return 'wl-paste --no-newline --type text/html'
    end

    return 'xclip -selection clipboard -o -t text/html'
  end

  if os_name == 'Windows' or os_name == 'Wsl' then
    return windows_html_command
  end

  return nil
end

local function get_text_command(os_name)
  if os_name == 'Darwin' then
    return 'pbpaste'
  end

  if os_name == 'Linux' then
    if vim.env.XDG_SESSION_TYPE == 'wayland' then
      return 'wl-paste --no-newline --type text/plain;charset=utf-8'
    end

    return 'xclip -selection clipboard -o -t text/plain'
  end

  if os_name == 'Windows' or os_name == 'Wsl' then
    return {
      'powershell.exe',
      '-NoProfile',
      '-Command',
      'Get-Clipboard -Raw',
    }
  end

  return nil
end

function M.read_image(callback)
  local os_name = get_os()
  local commands = get_image_commands(os_name)

  if not commands then
    callback(nil, 'unsupported-clipboard')
    return
  end

  vim.system(
    M.shell_command(commands.check),
    {
      text = true,
    },
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          callback(nil, 'clipboard-check-failed')
          return
        end

        local output = result.stdout or ''

        local has_image =
          output:find('image/png', 1, true) ~= nil
          or (
            os_name == 'Darwin'
            and output:sub(1, 9) == 'iVBORw0KG'
          )

        if not has_image then
          callback(nil, 'no-image')
          return
        end

        callback({
          os = os_name,
          commands = commands,
        }, nil)
      end)
    end
  )
end

function M.read_html(callback)
  local os_name = get_os()
  local command = get_html_command(os_name)

  if not command then
    callback(nil, 'unsupported-clipboard')
    return
  end

  vim.system(
    M.shell_command(command),
    {
      text = os_name ~= 'Windows' and os_name ~= 'Wsl',
    },
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          callback(nil, 'clipboard-read-failed')
          return
        end

        local html, err = cf_html.parse(result.stdout or '')
        callback(html, err)
      end)
    end
  )
end

function M.read_text(callback)
  local os_name = get_os()
  local command = get_text_command(os_name)

  if not command then
    callback(nil, 'unsupported-clipboard')
    return
  end

  vim.system(
    M.shell_command(command),
    { text = true },
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          callback(nil, 'clipboard-read-failed')
          return
        end

        callback(result.stdout or '', nil)
      end)
    end
  )
end

function M.shell_command(command)
  if type(command) == 'table' then
    return command
  end

  if jit.os == 'Windows' then
    return { 'powershell.exe', '-NoProfile', '-Command', command }
  end

  return { 'sh', '-c', command }
end

function M.detect(callback, check_html)
  M.read_image(function(image_info)
    if image_info then
      callback('image', image_info)
      return
    end

    if not check_html then
      callback('text', nil)
      return
    end

    M.read_html(function(html)
      if html then
        callback('html', html)
        return
      end

      callback('text', nil)
    end)
  end)
end

return M