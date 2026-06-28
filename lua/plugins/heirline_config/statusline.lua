local conditions = require('heirline.conditions')
local colors = require('plugins.heirline_config.colors')
local _lsp_args = { bufnr = 0 }

-- 1. Vi Mode
local ViMode = {
  update = true,
  init = function(self)
    self.mode = vim.fn.mode(1)
    self.mode_color = colors.mode_colors[self.mode] or 'normal'
  end,
  static = { mode_names = colors.mode_names },
  {
    provider = function(self)
      return '  ' .. (self.mode_names[self.mode] or self.mode) .. ' '
    end,
    hl = function(self) return { fg = 'bg', bg = self.mode_color, bold = true } end,
  },
  {
    provider = '',
    hl = function(self) return { fg = self.mode_color, bg = 'bright_bg' } end,
  },
  {
    provider = '',
    hl = { fg = 'bright_bg', bg = 'section_bg' }
  }
  --  - default : "" "" Will only work for default Statusline Theme
  --  - "round" : "" "" Will only work for default and minimal Statusline Theme
  --  - "block" : "█" "█" Will only work for default and minimal Statusline Theme
  --  - "arrow" : "" "" Will only work for default Statusline Theme
  -- { left = '', right = '' },
  -- { left = '', right = '' }
}

-- 2. Diagnostics
local Diagnostics = {
  condition = conditions.has_diagnostics,
  update = { 'DiagnosticChanged', 'BufEnter' },
  init = function(self)
    local counts = vim.diagnostic.count(0)
    self.errors = counts[vim.diagnostic.severity.ERROR] or 0
    self.warns = counts[vim.diagnostic.severity.WARN] or 0
    self.info = counts[vim.diagnostic.severity.INFO] or 0
    self.hints = counts[vim.diagnostic.severity.HINT] or 0
  end,
  hl = { bg = 'section_bg' },
  { provider = ' ' },
  { provider = function(self) return self.errors > 0 and (' ' .. self.errors .. ' ') or '' end, hl = { fg = 'diag_error' } },
  { provider = function(self) return self.warns > 0 and (' ' .. self.warns .. ' ') or '' end, hl = { fg = 'diag_warn' } },
  { provider = function(self) return self.info > 0 and (' ' .. self.info .. ' ') or '' end, hl = { fg = 'diag_info' } },
  { provider = function(self) return self.hints > 0 and (' ' .. self.hints .. ' ') or '' end, hl = { fg = 'diag_hint' } },
}

local DiagSep = { provider = '', hl = { fg = 'section_bg', bg = 'bg' } }

-- 3. Git Status
local Git = {
  condition = function()
    return vim.b.minidiff_summary ~= nil or (vim.b.my_git_branch and vim.b.my_git_branch ~= '')
  end,
  init = function(self)
    self.summary = vim.b.minidiff_summary or {}
    self.branch = vim.b.my_git_branch or ''
  end,
  {
    provider = function(self)
      return self.branch == '' and '' or (' 󰘬 ' .. self.branch .. ' ')
    end,
    hl = function()
      return { fg = require('custom.color-list').colors.aluminium.hex, bold = false }
    end,
  },
  {
    condition = function(self) return (self.summary.add or 0) > 0 end,
    provider = function(self) return '  ' .. self.summary.add .. ' ' end,
    hl = { fg = 'git_add' },
  },
  {
    condition = function(self) return (self.summary.change or 0) > 0 end,
    provider = function(self) return '  ' .. self.summary.change .. ' ' end,
    hl = { fg = 'git_change' },
  },
  {
    condition = function(self) return (self.summary.delete or 0) > 0 end,
    provider = function(self) return '  ' .. self.summary.delete .. ' ' end,
    hl = { fg = 'git_del' },
  },
  { provider = ' ' },
}

local Align = { provider = '%=' }

-- 4. Active LSP
local ActiveLSP = {
  update = { 'LspAttach', 'LspDetach', 'BufEnter' },
  provider = function()
    _lsp_args.bufnr = 0
    local clients = vim.lsp.get_clients(_lsp_args)
    local count = #clients
    if count == 0 then return '' end

    local names = {}
    local max_show = 2

    local limit = count > max_show and max_show or count

    for i = 1, limit do
      names[i] = clients[i].name
    end

    local text = table.concat(names, ' | ')

    if count > max_show then
      text = text .. ' (+' .. (count - max_show) .. ')'
    end

    return '   ' .. text .. ' '
  end,
  hl = { fg = 'lsp_name', bold = true, bg = 'bg' },
}

-- 5. Python Venv
local Venv = {
  condition = function() return vim.bo.filetype == 'python' end,
  update = { 'BufEnter', 'DirChanged' },
  provider = function()
    if not package.loaded['venv-selector'] then return '' end
    local venv = require('venv-selector').venv()
    if not venv then return '' end
    local venv_name = vim.fs.basename(venv)
    return '  ' .. venv_name
  end,
  hl = { fg = 'venv_name', bg = 'bg' },
}

-- 6. Location And Time
local function get_time_str()
  local hour = tonumber(os.date('%H'))
  local ampm = hour < 12 and 'AM' or 'PM'
  return '  ' .. os.date('%I:%M ') .. ampm .. ' '
end

local cached_time = get_time_str()

local function setup_time_updater()
  cached_time = get_time_str()
  local current_seconds = tonumber(os.date('%S'))
  local ms_until_next_minute = (60 - current_seconds) * 1000

  vim.defer_fn(function()
    vim.api.nvim_command('redrawstatus')
    setup_time_updater()
  end, ms_until_next_minute)
end
setup_time_updater()

local LocationAndTime = {
  init = function(self)
    self.mode = vim.fn.mode(1)
    self.mode_color = colors.mode_colors[self.mode] or 'normal'
  end,
  { provider = '', hl = { fg = 'section_bg', bg = 'bg' } },
  { provider = '  %l:%c ', hl = function(self) return { fg = self.mode_color, bg = 'section_bg' } end },
  { provider = '', hl = function(self) return { fg = self.mode_color, bg = 'section_bg' } end },
  {
    provider = function() return cached_time end,
    hl = function(self) return { fg = 'bg', bg = self.mode_color, bold = true } end,
  }
}

-- 7. Assembly StatusLine
local StatusLine = {
  {
    condition = function()
      local disabled_ft = {
        snacks_picker_list = false,
        snacks_picker_input = false,
        snacks_dashboard = true,
        snacks_terminal = false,
        snacks_notif = false
      }
      return disabled_ft[vim.bo.filetype]
    end,
    provider = '',
  },
  {
    condition = function()
      local disabled_ft = {
        snacks_picker_list = false,
        snacks_picker_input = false,
        snacks_dashboard = true,
        snacks_terminal = false,
        snacks_notif = false
      }
      return not disabled_ft[vim.bo.filetype]
    end,
    ViMode,
    Diagnostics,
    DiagSep,
    Git,
    Align,
    Venv,
    ActiveLSP,
    LocationAndTime,
  }
}

return StatusLine
