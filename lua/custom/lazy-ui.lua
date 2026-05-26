local M = {}

function M.open()
  local info = require('libs.plugin_info').get_info()
  local plugins = info.plugins

  local lines = {}
  local extmarks = {}
  local cur_line = ''
  local cur_col = 0
  local line_idx = 0

  local function new_line()
    if line_idx > 0 then table.insert(lines, cur_line) end
    cur_line = ''
    cur_col = 0
    line_idx = line_idx + 1
  end

  local function append(text, hl)
    if text == '' then return end
    if hl then
      table.insert(extmarks, {
        line = line_idx - 1,
        start_col = cur_col,
        end_col = cur_col + #text,
        hl_group = hl
      })
    end
    cur_line = cur_line .. text
    cur_col = cur_col + #text
  end

  new_line(); new_line()
  append('  ')
  append(' Home (H) ', 'CursorLine')
  append('  ', 'NONE')
  append(' Update (U) ', 'CursorLine')
  append('  ', 'NONE')
  append(' Search (S) ', 'CursorLine')
  append('  ', 'NONE')
  append(' Dir (D) ', 'CursorLine')
  append('  ', 'NONE')
  append(' Quit (q) ', 'CursorLine')

  new_line(); new_line()
  local ms = 0
  if _G.start_time and _G.end_time then
    ms = (_G.end_time - _G.start_time) / 1e6
  end
  append('  Startuptime: ', 'Title')
  append(string.format('%.2fms', ms), 'WarningMsg')
  append(' (Till UIEnter)', 'Comment')

  new_line(); new_line()
  append(string.format('  Total: %d plugins  Loaded: %d', info.total, info.loaded), 'Comment')
  new_line(); new_line()

  -- [第 4 行起]: 插件列表
  for _, p in ipairs(plugins) do
    new_line()
    append('  ')
    if p.loaded then
      append('● ', 'Statement')
      append('󰏗 ', 'Function')
      append(p.name, 'Normal')
    else
      append('○ ', 'Comment')
      append('󰏗 ', 'Comment')
      append(p.name, 'Comment')
    end
    append(string.format(' [%s]', p.type), 'Comment')
  end
  table.insert(lines, cur_line)

  local win = require('snacks').win({
    position = 'float',
    width = 0.65,
    height = 0.75,
    border = 'rounded',
    backdrop = 60,
    title = ' 󱑽 Resonance 󱑽 ',
    title_pos = 'center',
    zindex = 50,
    enter = true,
    bo = {
      modifiable = true,
      buftype = 'nofile',
      filetype = 'diy_lazy',
      swapfile = false,
      bufhidden = 'wipe',
    },
    wo = {
      cursorline = true,
      wrap = false,
      signcolumn = 'no',
      number = false,
      relativenumber = false,
    }
  })

  local buf = win.buf
  if not buf then return end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local ns = vim.api.nvim_create_namespace('diy_lazy_ui')
  for _, em in ipairs(extmarks) do
    pcall(vim.api.nvim_buf_set_extmark, buf, ns, em.line, em.start_col, {
      end_col = em.end_col,
      hl_group = em.hl_group,
      priority = 100,
    })
  end

  vim.bo[buf].modifiable = false

  vim.keymap.set('n', 'q', function() win:close() end, { buf = buf, nowait = true })
  vim.keymap.set('n', '<Esc>', function() win:close() end, { buf = buf, nowait = true })
  vim.keymap.set('n', 'H', 'gg', { buf = buf })

  vim.keymap.set('n', 'U', function()
    win:close()
    vim.pack.update()
    vim.notify('Triggering DIY plugin update...', vim.log.levels.INFO)
  end, { buf = buf, desc = 'Update Plugins' })

  local pack_dir = vim.fs.normalize(vim.fn.stdpath('data') .. '/site/pack')
  vim.keymap.set('n', 'S', function()
    win:close()
    require('snacks').picker.grep({
      dirs = { pack_dir },
      title = '  Grep in Plugins '
    })
  end, { buf = buf, nowait = true, desc = 'Search in Plugins Source' })

  vim.keymap.set('n', 'D', function()
    win:close()
    require('snacks').explorer({ cwd = pack_dir })
  end, { buf = buf, nowait = true, desc = 'Open Plugin Directory' })
end

return M
