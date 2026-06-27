local utils = require('heirline.utils')
local icon_lib = require('libs.icons')

-- =========================================================
-- ⚡ 1. 赋值优化法 (Localize C-API for extreme performance)
-- =========================================================
local api = vim.api
local bo = vim.bo
local schedule = vim.schedule
local str_byteindex = vim.str_byteindex
local str_utfindex = vim.str_utfindex
local str_sub = string.sub
local buf_get_name = api.nvim_buf_get_name
local get_opt = api.nvim_get_option_value
local set_current_buf = api.nvim_set_current_buf
local diag_count = vim.diagnostic.count
local severity = vim.diagnostic.severity
-- local list_tabpages = api.nvim_list_tabpages -- NOTE: pair with line 231

local _bpm, _icons, _snacks
local function get_bpm()
  if not _bpm then pcall(function() _bpm = require('bpm') end) end
  return _bpm
end
local function get_icons()
  if not _icons then pcall(function() _icons = require('mini.icons') end) end
  return _icons
end
local function get_snacks()
  if not _snacks then pcall(function() _snacks = require('snacks') end) end
  return _snacks
end

-- =========================================================
-- ⚙️ 2. BPM 缓冲池同步引擎 (实时获取，消灭任何延迟 Bug)
-- =========================================================
local function get_bufs()
  local bpm = get_bpm()
  if bpm then
    return bpm.get_attached_buf(0)
  end

  local all_bufs = api.nvim_list_bufs()
  local res = {}
  local idx = 1
  for i = 1, #all_bufs do
    local b = all_bufs[i]
    if bo[b].buflisted then
      res[idx] = b
      idx = idx + 1
    end
  end
  return res
end

local aug = api.nvim_create_augroup('Heirline_Tabline_Redraw', { clear = true })

api.nvim_create_autocmd(
  { 'VimEnter', 'UIEnter', 'BufAdd', 'BufDelete', 'BufEnter', 'TabEnter', 'TabClosed',
    'DiagnosticChanged' }, {
    group = aug,
    callback = function()
      schedule(function()
        vim.cmd('redrawtabline')
      end)
    end
  })

-- =========================================================
-- 📁 3. 核心 Buffer 渲染块
-- =========================================================
local TablineFileNameBlock = {
  init = function(self)
    self.filename = buf_get_name(self.bufnr)
    local bpm = get_bpm()

    if bpm then
      self.display_name = bpm.resolve_bufname(self.bufnr)
      if require('libs.utils').is_windows() then
        self.display_name = vim.fs.basename(self.filename)
      end
    else
      self.display_name = vim.fs.basename(self.filename)
    end

    self.is_modified = get_opt('modified', { buf = self.bufnr })

    local diags = diag_count(self.bufnr)
    self.errors = diags[severity.ERROR] or 0
    self.warns = diags[severity.WARN] or 0

    local icons = get_icons()
    if icons then
      local icon, hl = icons.get('file', self.filename)
      self.icon = icon
      self.icon_hl = hl
    end
  end,

  hl = function(self)
    return self.is_active and 'TabLineSel' or 'TabLine'
  end,

  on_click = {
    callback = function(_, minwid, _, button)
      if button == 'm' or button == 'r' then
        local bpm = get_bpm()
        if bpm then
          bpm.detach(minwid)
        else
          get_snacks().bufdelete(minwid, { wipe = true })
        end
      else
        set_current_buf(minwid)
      end
    end,
    minwid = function(self) return self.bufnr end,
    name = 'heirline_tabline_buffer_click',
  },

  { provider = '  ' },

  -- 📄 动态文件图标
  {
    provider = function(self)
      return self.icon and (self.icon .. ' ') or icon_lib.basic.file
    end,
    hl = function(self)
      return (self.is_active and self.icon_hl) and self.icon_hl or 'Comment'
    end,
  },

  -- 📝 文件名（智能超长截断）
  {
    provider = function(self)
      local name = self.display_name
      if name == '' then name = '[No Name]' end
      local max_len = 20
      if #name > max_len then
        local _, char_len = str_utfindex(name, #name)
        if char_len > max_len then
          local byte_idx = str_byteindex(name, max_len - 1)
          name = str_sub(name, 1, byte_idx) .. '…'
        end
      end
      return name
    end,
    hl = function(self)
      return { bold = self.is_active, italic = false }
    end,
  },

  -- 🛑 诊断指标
  {
    condition = function(self) return self.errors > 0 end,
    provider = function(self) return '  ' .. self.errors end,
    hl = { fg = 'diag_error' },
  },
  {
    condition = function(self) return self.warns > 0 end,
    provider = function(self) return '  ' .. self.warns end,
    hl = { fg = 'diag_warn' },
  },

  -- ❌ 关闭/修改状态 按钮
  {
    provider = function(self)
      return self.is_modified and icon_lib.basic.modify or icon_lib.basic.close
    end,
    hl = function(self)
      if self.is_modified then return { fg = 'command' } end

      return { fg = self.is_active and 'tab_cross_bg' or 'tab_num_unfocus' }
    end,
    on_click = {
      callback = function(_, minwid)
        local bpm = get_bpm()
        if bpm then
          bpm.detach(minwid)
        else
          get_snacks().bufdelete(minwid, { wipe = true })
        end
      end,
      minwid = function(self) return self.bufnr end,
      name = 'heirline_tabline_close_btn',
    },
  },

  { provider = ' ' },
}

-- 非活跃项加上垂直分隔线
local TablineBufferBlock = {
  TablineFileNameBlock,
  {
    -- provider = '│',
    provider = '|',
    hl = 'TabLine',
  },
}

-- =========================================================
-- 🏢 4. 顶层 Workspace Tab 渲染 (右侧区域)
-- =========================================================
local Tabpage = {
  provider = function(self)
    local bpm = get_bpm()
    local name = bpm and bpm.resolve_tabname(self.tabpage) or tostring(self.tabnr)
    return '%' .. self.tabnr .. 'T  ' .. name .. '  %T'
  end,
  hl = function(self)
    if self.is_active then
      return {
        fg = 'tab_num',
        bg = utils.get_highlight('TabLineSel').bg,
        bold = true
      }
    else
      return {
        fg = 'tab_num_unfocus',
        bg = utils.get_highlight('TabLine').bg,
        italic = false
      }
    end
  end,
}

local TabPages = {
  -- condition = function() return #list_tabpages() >= 2 end,
  utils.make_tablist(Tabpage),
  {
    provider = '%999X 󰅖 %X',
    hl = function()
      return {
        fg = 'tab_cross_fg',
        bg = 'tab_cross_bg',
      }
    end,
  }
}

-- =========================================================
-- 🚀 5. 终极装配 (带 %= 弹性空间)
-- =========================================================
local BufferLine = utils.make_buflist(
  TablineBufferBlock,
  { provider = '  ', hl = 'TabLine' },
  { provider = '  ', hl = 'TabLine' },
  get_bufs,
  false
)

local TabLine = {
  BufferLine,
  { provider = '%=', hl = 'TabLineFill' },
  TabPages,
}

return TabLine
