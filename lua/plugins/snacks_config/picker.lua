local icons = require('libs.icons')
local common_exclude = { '.git', '~', '.idea', '.DS_Store' }

return {
  enabled = true,
  matcher = {
    cwd_bonus = true, -- 当前目录加权。更倾向于当前路径下的文件
    frecency = true, -- 开启记忆加权。打开次数越多越靠前。
    sort_empty = true, --  首次打开时预览器就显示排序后的结果
  },
  hidden = true,
  prompt = ' ',
  layouts = {
    my_default_layout = {
      layout = {
        width = 0.8,
        height = 0.8,
        border = 'none',
        backdrop = false,
        box = 'horizontal',
        {
          box = 'vertical',
          { win = 'input', height = 1, border = 'rounded', title = '{title} {live} {flags}', title_pos = 'left' },
          { win = 'list', border = 'rounded' },
        },
        { win = 'preview', border = 'rounded', title = '{preview:Preview}', title_pos = 'left', width = 0.65 },
      },
    },
    my_vertical_layout = {
      layout = {
        width = 0.8,
        height = 0.9,
        border = 'rounded',
        backdrop = false,
        box = 'vertical',
        { win = 'input', border = 'rounded', height = 1, title = '{title} {live} {flags}', title_pos = 'left' },
        { win = 'list', border = 'rounded', height = 8 },
        { win = 'preview', border = 'rounded' },
      },
    },
  },
  layout = {
    preset = function()
      return vim.o.columns >= 100 and 'my_default_layout' or 'my_vertical_layout'
    end,
  },
  icons = {
    files = {
      enabled = true,
      dir = icons.basic.dir .. ' ',
      dir_open = icons.basic.dir_open .. ' ',
      file = icons.basic.file .. ' '
    },
    tree = {
      vertical = icons.basic.indent,
      middle = icons.basic.indent,
      last = icons.basic.indent,
    },
    git = {
      enabled = true,
      commit = icons.git.commit .. ' ',
      staged = icons.git.staged,
      added = icons.git.added,
      deleted = icons.git.deleted,
      ignored = icons.git.ignored,
      modified = icons.git.modified,
      renamed = icons.git.renamed,
      unmerged = icons.git.branch,
      untracked = icons.git.untracked,
    },
    diagnostics = {
      Error = icons.lsp.error .. ' ',
      Warn = icons.lsp.warn .. ' ',
      Hint = icons.lsp.hint .. ' ',
      Info = icons.lsp.info .. ' ',
    },
  },
  sources = {
    files = { exclude = common_exclude },
    grep = { exclude = common_exclude },
    explorer = {
      exclude = common_exclude,
      diagnostics = true,
      diagnostics_open = false,
      git_status = true,
      git_status_open = false,
      git_untracked = true,
      layout = function()
        return {
          preview = false,
          layout = {
            position = 'left',
            width = (vim.g.explorer_size or { width = 30 }).width,
            box = 'vertical',
            { win = 'input', height = 1, border = 'rounded', title = '{title} {live} {flags}', title_pos = 'center' },
            { win = 'list', border = 'none' },
            { win = 'preview', title = '{preview}', height = 0.4, border = 'top' },
          },
        }
      end,
      on_show = function(picker)
        local show = true
        local gap = 1
        local clamp_width = function(value) return math.max(20, math.min(42, value)) end
        local position = picker.resolved_layout.layout.position
        local rel = picker.layout.root
        local update = function(win)
          local border = win:border_size().left + win:border_size().right
          win.opts.row = vim.api.nvim_win_get_position(rel.win)[1]
          win.opts.height = 0.6
          if position == 'left' then
            win.opts.col = vim.api.nvim_win_get_width(rel.win) + gap
            win.opts.width = clamp_width(vim.o.columns - border - win.opts.col)
          end
          if position == 'right' then
            win.opts.col = -vim.api.nvim_win_get_width(rel.win) - gap
            win.opts.width = clamp_width(vim.o.columns - border + win.opts.col)
          end
          win:update()
        end

        local preview_win = Snacks.win.new {
          relative = 'editor', external = false, focusable = false,
          border = 'rounded', backdrop = false, show = show,
          bo = { filetype = 'snacks_float_preview', buftype = 'nofile', buflisted = false, swapfile = false, undofile = false },
          on_win = function(win) update(win) end,
        }

        rel:on('WinLeave', function()
          vim.schedule(function()
            if not picker:is_focused() then picker.preview.win:close() end
          end)
        end)
        rel:on('WinResized', function() update(preview_win) end)

        picker.preview.win = preview_win
        picker.main = preview_win.win

        local orig_show_preview = picker.show_preview
        picker._preview_timer = vim.uv.new_timer()

        picker.show_preview = function(self)
          if not self._preview_timer then return end
          self._preview_timer:stop()
          self._preview_timer:start(60, 0, vim.schedule_wrap(function()
            if self.preview and self.preview.win and self.preview.win:valid() then
              orig_show_preview(self)
            end
          end))
        end

        picker:show_preview()
      end,
      on_close = function(picker)
        if picker._preview_timer then
          picker._preview_timer:stop()
          if not picker._preview_timer:is_closing() then
            picker._preview_timer:close()
          end
          picker._preview_timer = nil
        end
        vim.g.explorer_size = picker.layout.root:size()
        picker.preview.win:close()
      end,
      actions = {
        toggle_preview = function(picker) picker.preview.win:toggle() end,
        explorer_add = function(picker)
          local item = picker:current()
          local dir = vim.fn.getcwd()
          if item and item.file then
            dir = vim.fn.isdirectory(item.file) == 1 and item.file or
              vim.fn.fnamemodify(item.file, ':h')
          end
          vim.ui.input({ prompt = 'Add a new file or directory (directories end with a "/"): ' },
            function(input)
              if not input or input == '' then return end
              local path = vim.fs.normalize(dir .. '/' .. input)
              local is_dir = input:sub(-1) == '/'
              local target_dir = is_dir and path or vim.fn.fnamemodify(path, ':h')
              if vim.fn.isdirectory(target_dir) == 0 then pcall(vim.fn.mkdir, target_dir, 'p') end
              if is_dir then
                picker:update()
              else
                local fd = io.open(path, 'w')
                if fd then
                  fd:close(); picker:update()
                end
                vim.schedule(function()
                  vim.cmd('edit ' .. vim.fn.fnameescape(path))
                  picker:close()
                  if not fd then
                    vim.notify(
                      '\n[Explorer] Read-only directory.\nFile opened in memory. Sudo will be required on save.',
                      vim.log.levels.WARN)
                  end
                end)
              end
            end)
        end,
      },
    }
  }
}
