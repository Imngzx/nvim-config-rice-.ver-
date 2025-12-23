---@module 'snacks'

local icons = require('libs.icons')

local common_exclude = { '.git', '~', '.idea', '.DS_Store' }

vim.pack.add({ 'https://github.com/folke/snacks.nvim' })
local Snacks = require('snacks')
Snacks.setup({
  -- https://github.com/folke/snacks.nvim/blob/main/docs/bigfile.md
  bigfile = { enabled = true },
  -- https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md
  dashboard = { enabled = false },
  -- https://github.com/folke/snacks.nvim/blob/main/docs/explorer.md
  explorer = { enabled = true },
  -- https://github.com/folke/snacks.nvim/blob/main/docs/indent.md
  image = { enabled = false },
  indent = { enabled = true },
  input = { enabled = false },
  notifier = { enabled = false },

  -- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
  picker = {
    enabled = true,
    -- Appearance
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
            { win = 'input', height = 1,       border = 'single', title = '{title} {live} {flags}', title_pos = 'left' },
            { win = 'list',  border = 'single' },
          },
          { win = 'preview', border = 'single', title = '{preview:Preview}', title_pos = 'left', width = 0.65 },
        },
      },
      my_vertical_layout = {
        layout = {
          width = 0.8,
          height = 0.9,
          border = 'none',
          backdrop = false,
          box = 'vertical',
          { win = 'input',   border = 'single', height = 1, title = '{title} {live} {flags}', title_pos = 'left' },
          { win = 'list',    border = 'single', height = 8 },
          { win = 'preview', border = 'single' },
        },
      },
    },
    layout = {
      --- Use the default layout or vertical if the window is too narrow
      preset = function()
        return vim.o.columns >= 100 and 'my_default_layout' or 'my_vertical_layout'
      end,
    },
    icons = {
      files = {
        enabled = true, -- show file icons
        dir = icons.basic.dir .. ' ',
        dir_open = icons.basic.dir_open .. ' ',
        file = icons.basic.file .. ' '
      },
      tree = {
        vertical = icons.basic.indent,
        middle   = icons.basic.indent,
        last     = icons.basic.indent,
      },
      git = {
        enabled   = true,                   -- show git icons
        commit    = icons.git.commit .. ' ', -- used by git log
        staged    = icons.git.staged,       -- staged changes; always overrides the type icons
        added     = icons.git.added,
        deleted   = icons.git.deleted,
        ignored   = icons.git.ignored,
        modified  = icons.git.modified,
        renamed   = icons.git.renamed,
        unmerged  = icons.git.branch,
        untracked = icons.git.untracked,
      },
      diagnostics = {
        Error = icons.lsp.error .. ' ',
        Warn  = icons.lsp.warn .. ' ',
        Hint  = icons.lsp.hint .. ' ',
        Info  = icons.lsp.info .. ' ',
      },
    },
    -- Specific
    sources = {
      files = { exclude = common_exclude },
      grep = { exclude = common_exclude },
      -- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md#explorer
      explorer = {
        exclude = common_exclude,
        diagnostics = true,
        diagnostics_open = false, -- forward to parent folder
        git_status = true,
        git_status_open = false,
        git_untracked = true,
        -- Layout
        layout = function()
          return {
            preview = false,
            layout = {
              position = 'left',
              width = (vim.g.explorer_size or { width = 30 }).width,
              box = 'vertical',
              { win = 'list',    border = 'none' },
              { win = 'preview', title = '{preview}', height = 0.4, border = 'top' },
            },
          }
        end,
        -- Show patch
        on_show = function(picker)
          local show = true
          local gap = 1
          local clamp_width = function(value)
            return math.max(20, math.min(50, value))
          end
          --
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
            relative = 'editor',
            external = false,
            focusable = false,
            border = 'single',
            backdrop = false,
            show = show,
            bo = {
              filetype = 'snacks_float_preview',
              buftype = 'nofile',
              buflisted = false,
              swapfile = false,
              undofile = false,
            },
            on_win = function(win)
              update(win)
              picker:show_preview()
            end,
          }
          rel:on('WinLeave', function()
            vim.schedule(function()
              if not picker:is_focused() then picker.preview.win:close() end
            end)
          end)
          rel:on('WinResized', function() update(preview_win) end)
          picker.preview.win = preview_win
          picker.main = preview_win.win
        end,
        on_close = function(picker)
          vim.g.explorer_size = picker.layout.root:size()
          picker.preview.win:close()
        end,
        actions = {
          --[[Override]]
          toggle_preview = function(picker) picker.preview.win:toggle() end,
        },
        -- win = {
        --   list = {
        --     keys = {
        --       ['<BS>'] = 'explorer_up',
        --       ['o'] = 'explorer_open', -- open with system application
        --       ['P'] = 'toggle_preview',
        --       ['u'] = 'explorer_update',
        --       ['<c-c>'] = 'tcd',
        --       ['<leader>fg'] = 'picker_grep',
        --       ['<c-t>'] = 'terminal',
        --       ['.'] = 'explorer_focus',
        --       ['I'] = 'toggle_ignored',
        --       ['H'] = 'toggle_hidden',
        --       ['Z'] = 'explorer_close_all',
        --       [']g'] = 'explorer_git_next',
        --       ['[g'] = 'explorer_git_prev',
        --       [']d'] = 'explorer_diagnostic_next',
        --       ['[d'] = 'explorer_diagnostic_prev',
        --       [']w'] = 'explorer_warn_next',
        --       ['[w'] = 'explorer_warn_prev',
        --       [']e'] = 'explorer_error_next',
        --       ['[e'] = 'explorer_error_prev',
        --     },
        --   },
        -- },
      }
    }
  },
  quickfile = { enabled = true },
  scope = { enabled = true },
  -- https://github.com/folke/snacks.nvim/blob/main/docs/scroll.md
  scroll = {
    enabled = true,
    animate = {
      duration = { step = 10, total = 50 },
      easing = 'linear',
    },
  },
  -- https://github.com/folke/snacks.nvim/blob/main/docs/statuscolumn.md
  statuscolumn = {
    enabled = true,
    folds = { open = true, }, -- show open fold icons
  },
  -- https://github.com/folke/snacks.nvim/blob/main/docs/words.md
  words = { enabled = true },
  -- https://github.com/folke/snacks.nvim/blob/main/docs/styles.md
  styles = {}
})

local key = {
  { '<leader>e',       function() Snacks.explorer() end,                    desc = 'File Explorer' },
  -- Find
  { '<leader><space>', function() Snacks.picker.smart() end,                desc = 'Smart find' },
  { '<leader>fg',      function() Snacks.picker.grep() end,                 desc = 'Grep' },
  { '<leader>fb',      function() Snacks.picker.buffers() end,              desc = 'Buffers' },
  { '<leader>ff',      function() Snacks.picker.git_files() end,            desc = 'Find git files' },
  { '<leader>fp',      function() Snacks.picker.projects() end,             desc = 'Projects' },
  { '<leader>fr',      function() Snacks.picker.registers() end,            desc = 'Registers' },
  -- { '<leader>fr', function() Snacks.picker.recent() end,               desc = 'Recent' },
  -- Grep
  { '<leader>fb',      function() Snacks.picker.lines() end,                desc = 'Buffer lines' },
  { '<leader>fB',      function() Snacks.picker.grep_buffers() end,         desc = 'Grep open buffers' },
  { '<leader>fw',      function() Snacks.picker.grep_word() end,            desc = 'Visual selection or word', mode = { 'n', 'x' } },
  -- git
  { '<leader>gB',      function() Snacks.gitbrowse() end,                   desc = 'Git browse',               mode = { 'n', 'v' } },
  { '<leader>gg',      function() Snacks.lazygit() end,                     desc = 'Lazygit' },
  { '<leader>gb',      function() Snacks.picker.git_branches() end,         desc = 'Git branches' },
  { '<leader>gl',      function() Snacks.picker.git_log() end,              desc = 'Git log' },
  { '<leader>gs',      function() Snacks.picker.git_status() end,           desc = 'Git status' },
  { '<leader>gS',      function() Snacks.picker.git_stash() end,            desc = 'Git stash' },
  { '<leader>gd',      function() Snacks.picker.git_diff() end,             desc = 'Git diff (hunks)' },
  -- search
  { '<leader>sc',      function() Snacks.picker.command_history() end,      desc = 'Command history' },
  { '<leader>s/',      function() Snacks.picker.search_history() end,       desc = 'Search history' },
  { '<leader>sa',      function() Snacks.picker.autocmds() end,             desc = 'Autocmds' },
  { '<leader>sC',      function() Snacks.picker.commands() end,             desc = 'Commands' },
  { '<leader>sh',      function() Snacks.picker.help() end,                 desc = 'Help pages' },
  { '<leader>sH',      function() Snacks.picker.highlights() end,           desc = 'Highlights' },
  { '<leader>si',      function() Snacks.picker.icons() end,                desc = 'Icons' },
  -- { '<leader>sj', function() Snacks.picker.jumps() end,                 desc = 'Jumps' },
  { '<leader>sk',      function() Snacks.picker.keymaps() end,              desc = 'Keymaps' },
  -- { '<leader>sl', function() Snacks.picker.loclist() end,               desc = 'Location list' },
  { '<leader>sm',      function() Snacks.picker.marks() end,                desc = 'Marks' },
  -- { '<leader>sM', function() Snacks.picker.man() end,                   desc = 'Man pages' },
  -- { '<leader>sp', function() Snacks.picker.lazy() end,                  desc = 'Search for plugin spec' },
  -- { '<leader>sq', function() Snacks.picker.qflist() end,                desc = 'Quickfix list' },
  -- { '<leader>sR', function() Snacks.picker.resume() end,                desc = 'Resume' },
  { '<leader>su',      function() Snacks.picker.undo() end,                 desc = 'Undo history' },
  -- { '<leader>uC', function() Snacks.picker.colorschemes() end,          desc = 'Colorschemes' },
  -- LSP
  { '<leader>cD',      function() Snacks.picker.diagnostics() end,          desc = 'Diagnostics' },
  { '<leader>cd',      function() Snacks.picker.diagnostics_buffer() end,   desc = 'Buffer diagnostics' },
  { 'gd',              function() Snacks.picker.lsp_definitions() end,      desc = 'Goto definition' },
  { 'gD',              function() Snacks.picker.lsp_declarations() end,     desc = 'Goto declaration' },
  { 'gr',              function() Snacks.picker.lsp_references() end,       nowait = true,                     desc = 'References' },
  { 'gI',              function() Snacks.picker.lsp_implementations() end,  desc = 'Goto implementation' },
  { 'gy',              function() Snacks.picker.lsp_type_definitions() end, desc = 'Goto t[y]pe definition' },
  -- { 'gai',        function() Snacks.picker.lsp_incoming_calls() end,    desc = 'C[a]lls incoming' },
  -- { 'gao',        function() Snacks.picker.lsp_outgoing_calls() end,    desc = 'C[a]lls outgoing' },
  -- { '<leader>ss', function() Snacks.picker.lsp_symbols() end,           desc = 'LSP symbols' },
  -- { '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'LSP workspace symbols' },
  -- Other
  { '<leader>uz',      function() Snacks.zen() end,                         desc = 'Toggle zen mode' },
  -- { '<leader>Z',  function() Snacks.zen.zoom() end,                    desc = 'Toggle zoom' },
  { '<leader>bs',      function() Snacks.scratch() end,                     desc = 'Toggle scratch buffer' },
  -- { '<leader>S',  function() Snacks.scratch.select() end,              desc = 'Select scratch buffer' },
  { '<leader>bd',      function() Snacks.bufdelete() end,                   desc = 'Delete buffer' },

  { '<leader>bo',      function() Snacks.bufdelete.other() end,             desc = 'Delete other buffers' },
  { '<leader>br',      function() Snacks.rename.rename_file() end,          desc = 'Rename file' },
  { '<c-/>',           function() Snacks.terminal() end,                    desc = 'Toggle terminal' },
  { ']]',              function() Snacks.words.jump(vim.v.count1) end,      desc = 'Next reference',           mode = { 'n', 't' } },
  { '[[',              function() Snacks.words.jump(-vim.v.count1) end,     desc = 'Prev reference',           mode = { 'n', 't' } },
  {
    '<leader>pN',
    desc = 'Neovim News',
    function()
      Snacks.win({
        file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
        width = 0.6,
        height = 0.6,
        wo = {
          spell = false,
          wrap = false,
          signcolumn = 'yes',
          statuscolumn = ' ',
          conceallevel = 3,
        },
      })
    end,
  }
}

-- Implement key registration
local set_keys = function(keys)
  for _, k in ipairs(keys) do
    local lhs = k[1]
    local rhs = k[2]
    if not lhs or not rhs then goto continue end

    local opts = {}
    if k.desc then opts.desc = k.desc end
    if k.nowait ~= nil then opts.nowait = k.nowait end
    if k.silent ~= nil then opts.silent = k.silent end
    if k.expr ~= nil then opts.expr = k.expr end
    if k.buffer ~= nil then opts.buffer = k.buffer end

    local mode = k.mode or 'n'
    if type(mode) == 'table' then
      for _, m in ipairs(mode) do
        vim.keymap.set(m, lhs, rhs, opts)
      end
    else
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    ::continue::
  end
end

-- apply mappings
set_keys(key)

local init_snacks = function()
  vim.api.nvim_create_autocmd('User', {
    pattern = 'VeryLazy',
    callback = function()
      -- Setup some globals for debugging (lazy-loaded)
      _G.dd = function(...)
        Snacks.debug.inspect(...)
      end
      -- _G.bt = function()
      --   Snacks.debug.backtrace()
      -- end

      -- Override print to use snacks for `:=` command
      if vim.fn.has('nvim-0.11') == 1 then
        vim._print = function(_, ...)
          dd(...)
        end
      else
        vim.print = _G.dd
      end

      -- Create some toggle mappings
      Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>us')
      Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
      Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map('<leader>uL')
      Snacks.toggle.diagnostics():map('<leader>ud')
      Snacks.toggle.line_number():map('<leader>ul')
      Snacks.toggle.option('conceallevel',
        { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map('<leader>uc')
      Snacks.toggle.treesitter():map('<leader>uT')
      Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' })
        :map('<leader>ub')
      Snacks.toggle.inlay_hints():map('<leader>uh')
      Snacks.toggle.indent():map('<leader>ug')
      Snacks.toggle.dim():map('<leader>uD')
    end,
  })
end

init_snacks()
