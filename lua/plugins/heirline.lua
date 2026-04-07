local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/rebelot/heirline.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  setup = function()
    local heirline = require('heirline')
    local conditions = require('heirline.conditions')
    local utils = require('heirline.utils')

    local function setup_colors()
      return {
        bg = utils.get_highlight('StatusLine').bg or '#1e1e2e',
        fg = utils.get_highlight('StatusLine').fg or '#cdd6f4',

        bright_bg = utils.get_highlight('Folded').bg or '#45475a', -- 亮灰色（紧跟在 Normal 后面）
        section_bg = utils.get_highlight('CursorLine').bg or '#313244', -- 暗灰色（诊断信息的背景，保持不变）

        normal = utils.get_highlight('Directory').fg or '#89b4fa',
        insert = utils.get_highlight('String').fg or '#a6e3a1',
        visual = utils.get_highlight('Statement').fg or '#cba6f7',
        replace = utils.get_highlight('Error').fg or '#f38ba8',
        -- command = '#fab387' or utils.get_highlight('WarningMsg'),
        command = utils.get_highlight('WarningMsg').fg or '#fab387',
        terminal = '#fab387',
        diag_error = utils.get_highlight('DiagnosticError').fg,
        diag_warn = utils.get_highlight('DiagnosticWarn').fg,
        diag_info = utils.get_highlight('DiagnosticInfo').fg,
        diag_hint = utils.get_highlight('DiagnosticHint').fg,
        -- git_add = utils.get_highlight('DiffAdd').fg,
        -- git_change = utils.get_highlight('DiffChange').fg,
        -- git_del = utils.get_highlight('DiffDelete').fg,
        git_add = utils.get_highlight('MiniDiffSignAdd').fg or '#a6e3a1',
        git_change = utils.get_highlight('MiniDiffSignChange').fg or '#f9e2af',
        git_del = utils.get_highlight('MiniDiffSignDelete').fg or '#f38ba8',
      }
    end

    heirline.load_colors(setup_colors())

    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = function() utils.on_colorscheme(setup_colors) end,
    })

    local mode_names = {
      n = 'NORMAL',
      i = 'INSERT',
      v = 'VISUAL',
      V = 'V-LINE',
      ['\22'] = 'V-BLOCK',
      c = 'COMMAND',
      s = 'SELECT',
      S = 'S-LINE',
      ['\19'] = 'S-BLOCK',
      R = 'REPLACE',
      r = 'PROMPT',
      rm = 'MORE',
      ['r?'] = 'CONFIRM',
      x = 'CONFIRM',
      ['!'] = 'SHELL',
      t = 'TERMINAL',
    }
    local mode_colors = {
      n = 'normal',
      i = 'insert',
      v = 'visual',
      V = 'visual',
      ['\22'] = 'visual',
      c = 'command',
      s = 'visual',
      S = 'visual',
      ['\19'] = 'visual',
      R = 'replace',
      r = 'replace',
      rm = 'replace',
      ['r?'] = 'replace',
      x = 'replace',
      ['!'] = 'command',
      t = 'terminal',
    }

    local ViMode = {
      init = function(self)
        self.mode = vim.fn.mode(1)
        self.mode_color = mode_colors[self.mode] or 'normal'
      end,
      static = { mode_names = mode_names },
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
    }

    -- diagnostic
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

    -- git status
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
          -- return self.branch == '' and '' or ('  ' .. self.branch .. ' ')
          return self.branch == '' and '' or (' 󰘬 ' .. self.branch .. ' ')
        end,
        hl = { fg = 'fg', bold = false },
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

    -- shows lsp name
    local ActiveLSP = {
      update = { 'LspAttach', 'LspDetach', 'BufEnter' },
      provider = function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then return '' end

        local names = {}
        for _, server in ipairs(clients) do
          table.insert(names, server.name)
        end
        return '   ' .. table.concat(names, ' | ') .. ' '
      end,
      hl = { fg = 'fg', bold = true, bg = 'bg' },
    }

    -- python venv
    local Venv = {
      condition = function() return vim.bo.filetype == 'python' end,
      update = { 'BufEnter', 'DirChanged' },
      provider = function()
        if not package.loaded['venv-selector'] then return '' end
        local venv = require('venv-selector').venv()
        return venv and ('  ' .. (string.match(venv, '([^/]+)$') or venv)) or ''
      end,
      hl = { fg = 'insert', bg = 'bg' },
    }

    -- time
    local cached_time = os.date('  %I:%M %p ')
    local function setup_time_updater()
      cached_time = os.date('  %I:%M %p ')
      -- 计算距离下一分钟的第 0 秒还有多少毫秒
      local current_seconds = tonumber(os.date('%S'))
      local ms_until_next_minute = (60 - current_seconds) * 1000

      -- 精准等待到下一分钟的开头
      vim.defer_fn(function()
        vim.cmd('redrawstatus') -- 通知状态栏刷新
        setup_time_updater() -- 循环下一个一分钟
      end, ms_until_next_minute)
    end
    setup_time_updater()
    local LocationAndTime = {
      init = function(self)
        self.mode = vim.fn.mode(1)
        self.mode_color = mode_colors[self.mode] or 'normal'
      end,
      { provider = '', hl = { fg = 'section_bg', bg = 'bg' } },
      { provider = '  %l:%c ', hl = { fg = 'normal', bg = 'section_bg' } },
      { provider = '', hl = function(self) return { fg = self.mode_color, bg = 'section_bg' } end },
      {
        provider = function() return cached_time end,
        hl = function(self) return { fg = 'bg', bg = self.mode_color, bold = true } end,
      }
    }

    local StatusLine = {
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
    -- this is from the custom.statusline
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'FocusGained' }, {
      group = vim.api.nvim_create_augroup('HeirlineGitBranch', { clear = true }),
      callback = function(args)
        local bufnr = args.buf
        if vim.bo[bufnr].buftype ~= '' or vim.b[bufnr].my_git_fetching then return end
        local filepath = vim.api.nvim_buf_get_name(bufnr)
        if filepath == '' or filepath:match('^[%w%+%.%-]+://') then return end

        local dir = vim.fn.fnamemodify(filepath, ':h')
        vim.b[bufnr].my_git_fetching = true

        vim.system({ 'git', '-C', dir, 'rev-parse', '--abbrev-ref', 'HEAD' },
          { text = true, timeout = 1000 },
          function(obj)
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(bufnr) then
                vim.b[bufnr].my_git_fetching = false
                local new_branch = (obj.code == 0 and obj.stdout) and vim.trim(obj.stdout) or ''
                if vim.b[bufnr].my_git_branch ~= new_branch then
                  vim.b[bufnr].my_git_branch = new_branch
                  vim.cmd('redrawstatus')
                end
              end
            end)
          end)
      end,
    })
    heirline.setup({ statusline = StatusLine })
  end
})
