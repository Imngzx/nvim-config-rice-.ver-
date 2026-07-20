local M = {}

function M.setup()
  local cwd = vim.uv.cwd()
  if not cwd then return end

  local matches = vim.fs.find('.nvim.lua', { path = cwd, upward = true, limit = 1 })
  local local_config = matches[1]

  if not local_config then return end

  local utils = require('libs.utils')
  if utils.is_windows() then
    local_config = vim.fs.normalize(local_config)
  end

  if vim.uv.fs_stat(local_config) then
    local content = vim.secure.read(local_config)

    if type(content) == 'string' and content ~= '' then
      local chunk, syntax_err = load(content, '@' .. local_config)

      if not chunk then
        vim.notify(
          string.format('\n[Workspace] Syntax error in %s:\n%s', local_config, syntax_err),
          vim.log.levels.ERROR
        )
        return
      end

      local ok, exec_err = xpcall(chunk, debug.traceback)
      if not ok then
        vim.notify(
          string.format('\n[Workspace] Execution error in %s:\n%s', local_config, exec_err),
          vim.log.levels.ERROR
        )
      end
    end
  end
end

function M.picker()
  local api = vim.api
  local nvim_win_get_buf = api.nvim_win_get_buf
  local nvim_buf_get_name = api.nvim_buf_get_name
  local nvim_tabpage_get_win = api.nvim_tabpage_get_win
  local nvim_get_option_value = api.nvim_get_option_value

  local ok, bpm = pcall(require, 'bpm')
  local cur_tab = api.nvim_get_current_tabpage()
  local tabs = api.nvim_list_tabpages()
  local is_ac = require('libs.power').is_ac()

  local items = {}

  for i = 1, #tabs do
    local tab = tabs[i]
    local name = ok and bpm.resolve_tabname(tab) or ('Tab ' .. tab)

    -- 找回你丢失的 Buffer 数量计算逻辑
    local buf_count = 0
    if ok and bpm.get_attached_buf then
      local attached_bufs = bpm.get_attached_buf(tab)
      buf_count = attached_bufs and #attached_bufs or 0
    else
      local unique_bufs = {}
      local wins = api.nvim_tabpage_list_wins(tab)
      for w = 1, #wins do
        local b = nvim_win_get_buf(wins[w])
        if not unique_bufs[b] and nvim_get_option_value('buflisted', { buf = b }) then
          unique_bufs[b] = true
          buf_count = buf_count + 1
        end
      end
    end

    local focused_win = nvim_tabpage_get_win(tab)
    local focused_buf = nvim_win_get_buf(focused_win)
    local buf_name = nvim_buf_get_name(focused_buf)
    local active_file = buf_name:match('[^/\\]+$') or '[No Name]'

    items[i] = {
      text = name,
      tabpage = tab,
      is_current = (tab == cur_tab),
      buf_count = buf_count,
      active_file = active_file,
      -- fzf-lua 需要的纯文本排版
      fzf_str = string.format('%s %s [%d bufs] %s', tab == cur_tab and '󰓩' or '󰓨', name, buf_count,
        active_file)
    }
  end

  if is_ac then
    -- 完全还原你的 Snacks.picker 配置
    require('snacks').picker({
      title = ' 🏢 Workspaces ',
      items = items,
      layout = {
        preset = 'select',
        layout = {
          width = 0.45,
          height = 0.4,
          border = 'rounded',
          box = 'vertical',
          { win = 'input', height = 1, border = 'bottom' },
          { win = 'list', border = 'none' },
        }
      },
      format = function(item, _)
        local is_cur = item.is_current

        local hl_text = is_cur and 'DiagnosticOk' or 'Normal'
        local hl_icon = is_cur and 'DiagnosticOk' or 'DiagnosticHint'
        local icon = is_cur and '󰓩 ' or '󰓨 '
        local suffix = is_cur and ' (Current)' or ''

        return {
          { ' ' .. icon .. ' ', hl_icon },
          { item.text .. suffix, hl_text },
          { '  [' .. item.buf_count .. ' bufs]', 'Comment' },
          { ' 󰍎 ' .. item.active_file, 'NonText' },
        }
      end,
      confirm = function(picker, item)
        picker:close()
        if item and api.nvim_tabpage_is_valid(item.tabpage) then
          api.nvim_set_current_tabpage(item.tabpage)
        end
      end,
    })
  else
    -- Fzf-lua 极致性能版 (电池模式)
    local fzf_items = {}
    local item_map = {}
    for i = 1, #items do
      table.insert(fzf_items, items[i].fzf_str)
      item_map[items[i].fzf_str] = items[i]
    end
    require('fzf-lua').fzf_exec(fzf_items, {
      prompt = 'Workspace> ',
      actions = {
        ['default'] = function(selected)
          local item = item_map[selected[1]]
          if item and api.nvim_tabpage_is_valid(item.tabpage) then
            api.nvim_set_current_tabpage(item.tabpage)
          end
        end
      }
    })
  end
end

return M
