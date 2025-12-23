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
  indent = { enabled = true },
  input = { enabled = false },
  notifier = { enabled = false },
  -- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
  picker = {
    enabled = true,
    layout = {
      --- Use the default layout or vertical if the window is too narrow
      preset = function()
        return vim.o.columns >= 100 and 'default' or 'vertical'
      end,
    },
    previewers = {
      diff = {
      },
    },
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
  statuscolumn = {
    enabled = true,
    left = { 'mark', 'sign', 'git' }, -- priority of signs on the left (high to low)
    right = { 'fold' },               -- priority of signs on the right (high to low)
  },
  -- https://github.com/folke/snacks.nvim/blob/main/docs/words.md
  words = { enabled = true },
  -- https://github.com/folke/snacks.nvim/blob/main/docs/styles.md
  styles = {}
})

local key = {
  { '<leader>e',  function() Snacks.explorer() end,                    desc = 'File Explorer' },
  -- Find
  {
    '<leader><space>',
    function() Snacks.picker.smart() end,
    desc = 'Smart Find Files'
  },
  { '<leader>fb', function() Snacks.picker.buffers() end,              desc = 'Buffers' },
  { '<leader>fg', function() Snacks.picker.grep() end,                 desc = 'Grep' },
  { '<leader>fb', function() Snacks.picker.buffers() end,              desc = 'Buffers' },
  { '<leader>ff', function() Snacks.picker.git_files() end,            desc = 'Find git files' },
  { '<leader>fp', function() Snacks.picker.projects() end,             desc = 'Projects' },
  { '<leader>fr', function() Snacks.picker.recent() end,               desc = 'Recent' },
  { '<leader>fr', function() Snacks.picker.registers() end,            desc = 'Registers' },
  -- Grep
  { '<leader>fb', function() Snacks.picker.lines() end,                desc = 'Buffer lines' },
  { '<leader>fB', function() Snacks.picker.grep_buffers() end,         desc = 'Grep open Buffers' },
  { '<leader>fw', function() Snacks.picker.grep_word() end,            desc = 'Visual selection or word', mode = { 'n', 'x' } },
  -- git
  { '<leader>gB', function() Snacks.gitbrowse() end,                   desc = 'Git Browse',               mode = { 'n', 'v' } },
  { '<leader>gg', function() Snacks.lazygit() end,                     desc = 'Lazygit' },
  { '<leader>gb', function() Snacks.picker.git_branches() end,         desc = 'Git branches' },
  { '<leader>gl', function() Snacks.picker.git_log() end,              desc = 'Git log' },
  { '<leader>gs', function() Snacks.picker.git_status() end,           desc = 'Git status' },
  { '<leader>gS', function() Snacks.picker.git_stash() end,            desc = 'Git stash' },
  { '<leader>gd', function() Snacks.picker.git_diff() end,             desc = 'Git diff (hunks)' },
  -- search
  { '<leader>sc', function() Snacks.picker.command_history() end,      desc = 'Command history' },
  { '<leader>s/', function() Snacks.picker.search_history() end,       desc = 'Search history' },
  { '<leader>sa', function() Snacks.picker.autocmds() end,             desc = 'Autocmds' },
  { '<leader>sC', function() Snacks.picker.commands() end,             desc = 'Commands' },
  { '<leader>sh', function() Snacks.picker.help() end,                 desc = 'Help pages' },
  { '<leader>sH', function() Snacks.picker.highlights() end,           desc = 'Highlights' },
  { '<leader>si', function() Snacks.picker.icons() end,                desc = 'Icons' },
  -- { '<leader>sj', function() Snacks.picker.jumps() end,                 desc = 'Jumps' },
  { '<leader>sk', function() Snacks.picker.keymaps() end,              desc = 'Keymaps' },
  -- { '<leader>sl', function() Snacks.picker.loclist() end,               desc = 'Location List' },
  { '<leader>sm', function() Snacks.picker.marks() end,                desc = 'Marks' },
  -- { '<leader>sM', function() Snacks.picker.man() end,                   desc = 'Man Pages' },
  -- { '<leader>sp', function() Snacks.picker.lazy() end,                  desc = 'Search for Plugin Spec' },
  -- { '<leader>sq', function() Snacks.picker.qflist() end,                desc = 'Quickfix List' },
  -- { '<leader>sR', function() Snacks.picker.resume() end,                desc = 'Resume' },
  { '<leader>su', function() Snacks.picker.undo() end,                 desc = 'Undo History' },
  -- { '<leader>uC', function() Snacks.picker.colorschemes() end,          desc = 'Colorschemes' },
  -- LSP
  { '<leader>cD', function() Snacks.picker.diagnostics() end,          desc = 'Diagnostics' },
  { '<leader>cd', function() Snacks.picker.diagnostics_buffer() end,   desc = 'Buffer diagnostics' },
  { 'gd',         function() Snacks.picker.lsp_definitions() end,      desc = 'Goto Definition' },
  { 'gD',         function() Snacks.picker.lsp_declarations() end,     desc = 'Goto Declaration' },
  { 'gr',         function() Snacks.picker.lsp_references() end,       nowait = true,                     desc = 'References' },
  { 'gI',         function() Snacks.picker.lsp_implementations() end,  desc = 'Goto Implementation' },
  { 'gy',         function() Snacks.picker.lsp_type_definitions() end, desc = 'Goto T[y]pe Definition' },
  -- { 'gai',        function() Snacks.picker.lsp_incoming_calls() end,    desc = 'C[a]lls Incoming' },
  -- { 'gao',        function() Snacks.picker.lsp_outgoing_calls() end,    desc = 'C[a]lls Outgoing' },
  -- { '<leader>ss', function() Snacks.picker.lsp_symbols() end,           desc = 'LSP Symbols' },
  -- { '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'LSP Workspace Symbols' },
  -- Other
  { '<leader>uz', function() Snacks.zen() end,                         desc = 'Toggle Zen Mode' },
  -- { '<leader>Z',  function() Snacks.zen.zoom() end,                    desc = 'Toggle Zoom' },
  { '<leader>bs', function() Snacks.scratch() end,                     desc = 'Toggle Scratch buffer' },
  -- { '<leader>S',  function() Snacks.scratch.select() end,              desc = 'Select Scratch buffer' },
  { '<leader>bd', function() Snacks.bufdelete() end,                   desc = 'Delete Buffer' },
  -- { '<leader>cR', function() Snacks.rename.rename_file() end,          desc = 'Rename File' },
  { '<c-/>',      function() Snacks.terminal() end,                    desc = 'Toggle Terminal' },
  { ']]',         function() Snacks.words.jump(vim.v.count1) end,      desc = 'Next Reference',           mode = { 'n', 't' } },
  { '[[',         function() Snacks.words.jump(-vim.v.count1) end,     desc = 'Prev Reference',           mode = { 'n', 't' } },
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
