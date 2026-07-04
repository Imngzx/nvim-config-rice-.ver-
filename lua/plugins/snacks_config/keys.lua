return {
  -- ==========================================
  -- 📂 [ Explorer & Dashboard ]
  -- ==========================================
  { '<leader>e', function() Snacks.explorer() end, desc = 'File Explorer' },
  { '<leader>H', function() Snacks.dashboard() end, desc = 'Open Dashboard (Home)' },

  -- ==========================================
  -- 🔍 [ Pickers: Find & Grep ]
  -- ==========================================
  { '<leader><leader>', function() Snacks.picker.smart() end, desc = 'Smart find' },
  { '<leader>/', function() Snacks.picker.grep() end, desc = 'Grep' },
  { '<leader>fc', function() Snacks.picker.files({ cwd = vim.fn.stdpath('config') }) end, desc = 'Find Neovim Config' },
  { '<leader>fC', function() Snacks.picker.grep({ cwd = vim.fn.stdpath('config') }) end, desc = 'Grep Neovim Config' },
  { '<leader>ff', function() Snacks.picker.git_files() end, desc = 'Find git files' },
  { '<leader>fp', function() Snacks.picker.projects() end, desc = 'Projects' },
  { '<leader>fz', function() Snacks.picker.zoxide() end, desc = 'Zoxide (Recent Dirs)' },
  { '<leader>fl', function() Snacks.picker.lines() end, desc = 'Buffer lines' },
  { '<leader>fB', function() Snacks.picker.grep_buffers() end, desc = 'Grep open buffers' },
  { '<leader>fw', function() Snacks.picker.grep_word() end, desc = 'Visual selection or word', mode = { 'n', 'x' } },

  -- ==========================================
  -- 📜 [ Pickers: History, System & Registers ]
  -- ==========================================
  { '<leader>fb', function() Snacks.picker.buffers() end, desc = 'Buffers' },
  { '<leader>fr', function() Snacks.picker.registers() end, desc = 'Registers' },
  { '<leader>sc', function() Snacks.picker.command_history() end, desc = 'Command history' },
  { '<leader>s/', function() Snacks.picker.search_history() end, desc = 'Search history' },
  { '<leader>sn', function() Snacks.picker.notifications() end, desc = 'Notification history' },
  { '<leader>sa', function() Snacks.picker.autocmds() end, desc = 'Autocmds' },
  { '<leader>sC', function() Snacks.picker.commands() end, desc = 'Commands' },
  { '<leader>sh', function() Snacks.picker.help() end, desc = 'Help pages' },
  { '<leader>sH', function() Snacks.picker.highlights() end, desc = 'Highlights' },
  { '<leader>si', function() Snacks.picker.icons() end, desc = 'Icons' },
  { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Keymaps' },
  { '<leader>sm', function() Snacks.picker.marks() end, desc = 'Marks' },
  { '<leader>su', function() Snacks.picker.undo() end, desc = 'Undo history' },

  -- ==========================================
  -- 🐙 [ Git ]
  -- ==========================================
  { '<leader>gl', function() Snacks.picker.git_log() end, desc = 'Git log' },
  { '<leader>gL', function() Snacks.gitbrowse() end, desc = 'Git browse link', mode = { 'n', 'v' } },
  { '<leader>gb', function() Snacks.git.blame_line() end, desc = 'Git blame line' },
  { '<leader>gB', function() Snacks.picker.git_branches() end, desc = 'Git branches' },
  { '<leader>gg', function() Snacks.lazygit() end, desc = 'Lazygit' },
  { '<leader>gs', function() Snacks.picker.git_status() end, desc = 'Git status' },
  { '<leader>gS', function() Snacks.picker.git_stash() end, desc = 'Git stash' },
  { '<leader>gD', function() Snacks.picker.git_diff() end, desc = 'Git diff (hunks)' },
  { '<leader>ub', function() require('custom.git-blame').toggle() end, desc = 'Toggle Git Blame' },

  -- ==========================================
  -- 💡 [ LSP & Diagnostics ]
  -- ==========================================
  { '<leader>co', function() Snacks.picker.lsp_symbols() end, desc = 'LSP symbols' },
  { '<leader>cD', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
  { '<leader>cd', function() Snacks.picker.diagnostics_buffer() end, desc = 'Buffer diagnostics' },
  { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto definition' },
  { 'gD', function() Snacks.picker.lsp_declarations() end, desc = 'Goto declaration' },
  { 'gr', function() Snacks.picker.lsp_references() end, nowait = true, desc = 'References' },
  { 'gI', function() Snacks.picker.lsp_implementations() end, desc = 'Goto implementation' },
  { 'gy', function() Snacks.picker.lsp_type_definitions() end, desc = 'Goto t[y]pe definition' },
  { ']]', function() Snacks.words.jump(vim.v.count1) end, desc = 'Next reference', mode = { 'n', 't' } },
  { '[[', function() Snacks.words.jump(-vim.v.count1) end, desc = 'Prev reference', mode = { 'n', 't' } },

  -- ==========================================
  -- 🪟 [ Buffer & Window Management ]
  -- ==========================================
  {
    '<leader>bd',
    function()
      local ok, bpm = pcall(require, 'bpm')
      if ok then bpm.detach() else Snacks.bufdelete(0, { wipe = true }) end
    end,
    desc = 'Detach / Wipeout buffer'
  },
  {
    '<leader>bo',
    function()
      local ok, bpm = pcall(require, 'bpm')
      if ok then
        local current_buf = vim.api.nvim_get_current_buf()
        local tab_bufs = bpm.get_attached_buf(0)
        for i = 1, #tab_bufs do
          local buf = tab_bufs[i]
          if buf ~= current_buf then
            bpm.detach(buf)
          end
        end
      else
        Snacks.bufdelete.other({ wipe = true })
      end
    end,
    desc = 'Detach other buffers in Workspace'
  },
  {
    '<leader>bD',
    function()
      local ok, bpm = pcall(require, 'bpm')
      if ok then bpm.evict() else Snacks.bufdelete(0, { wipe = true }) end
    end,
    desc = 'Evict buffer from ALL Workspaces'
  },

  -- ==========================================
  -- 🏢 [ Workspace Picker ]
  -- ==========================================
  {
    '<leader>ft',
    function()
      local api = vim.api
      local nvim_win_get_buf = api.nvim_win_get_buf
      local nvim_buf_get_name = api.nvim_buf_get_name
      local nvim_tabpage_get_win = api.nvim_tabpage_get_win
      local nvim_get_option_value = api.nvim_get_option_value

      local ok, bpm = pcall(require, 'bpm')
      local cur_tab = api.nvim_get_current_tabpage()
      local tabs = api.nvim_list_tabpages()
      local items = {}

      for i = 1, #tabs do
        local tab = tabs[i]
        local name = ok and bpm.resolve_tabname(tab) or ('Tab ' .. tab)

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
        }
      end

      Snacks.picker({
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
    end,
    desc = 'Find Workspace (Tab)'
  },
  { '<leader>br', function() Snacks.rename.rename_file() end, desc = 'Rename file' },
  { '<leader>bs', function() Snacks.scratch() end, desc = 'Toggle scratch buffer' },

  -- ==========================================
  -- 🛠️ [ Utility & Toggles ]
  -- ==========================================
  { '<leader>st', function() require('custom.todo').search() end, desc = 'Search TODOs' },
  { '<leader>pT', function() Snacks.terminal() end, desc = 'Toggle half terminal' },
  { '<leader>uz', function() Snacks.zen() end, desc = 'Toggle zen mode' },
  { '<leader>uZ', function() Snacks.zen.zoom() end, desc = 'Toggle Zoom (Maximize window)' },

  -- Profiler
  { '<leader>spp', function() Snacks.profiler.toggle() end, desc = 'Toggle Profiler' },
  { '<leader>sps', function() Snacks.profiler.scratch() end, desc = 'Profiler Scratch Buffer' },

  -- Neovim News
  {
    '<leader>pN',
    desc = 'Neovim News',
    function()
      Snacks.win({
        file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
        width = 0.8,
        height = 0.8,
        border = 'rounded',
        backdrop = 60,
        title = ' 📰 News ',
        title_pos = 'center',
        wo = { spell = false, wrap = false, signcolumn = 'yes', statuscolumn = ' ', conceallevel = 3 },
      })
    end,
  },
  { '<leader>zn', function() require('custom.zettel').new_card() end, desc = 'Zettel: New Card' },
}
