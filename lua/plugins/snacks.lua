---@module 'snacks'

local lazy = require('libs.lazy')
local utils = require('libs.utils')

-- 1. 加载核心插件
vim.pack.add({ 'https://github.com/folke/snacks.nvim' })
local Snacks = require('snacks')

-- 2. 组装化配置（加载刚刚拆分出来的文件！）
Snacks.setup({
  bigfile = {
    enabled = true,
    notify = true,
    size = 1.5 * 1024 * 1024, -- 1.5MB
    setup = function(ctx)
      vim.schedule(function()
        vim.bo[ctx.buf].syntax = ctx.ft
      end)
    end,
  },
  explorer = { enabled = true },
  image = { enabled = true },
  indent = { enabled = true },
  input = { enabled = false },
  profiler = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  words = { enabled = true },
  styles = {},
  scroll = {
    enabled = true,
    animate = { duration = { step = 10, total = 50 }, easing = 'linear' },
  },
  statuscolumn = {
    enabled = true,
    folds = { open = true, git_hl = true },
  },
  notifier = {
    enabled = true,
    timeout = 3000,
    width = { min = 40, max = 0.4 },
    height = { min = 1, max = 0.1 },
    margin = { top = 1, right = 1, bottom = 1 },
    padding = true,
    sort = { 'level', 'added' },
    style = 'compact',
    top_down = true,
    date_format = '%R',
    refresh = 150,
  },

  dashboard = require('plugins.snacks_config.dashboard'),
  picker = require('plugins.snacks_config.picker'),
})

-- 3. 读取分离出去的按键配置
local key = require('plugins.snacks_config.keys')

local set_keys = function(keys)
  for _, k in ipairs(keys) do
    local lhs, rhs = k[1], k[2]
    if not lhs or not rhs then goto continue end

    local opts = {}
    if k.desc then opts.desc = k.desc end
    if k.nowait ~= nil then opts.nowait = k.nowait end
    if k.silent ~= nil then opts.silent = k.silent end
    if k.expr ~= nil then opts.expr = k.expr end
    if k.buffer ~= nil then opts.buf = k.buffer end

    local mode = k.mode or 'n'
    if type(mode) == 'table' then
      for _, m in ipairs(mode) do vim.keymap.set(m, lhs, rhs, opts) end
    else
      vim.keymap.set(mode, lhs, rhs, opts)
    end
    ::continue::
  end
end

-- 4. 依托你精湛的按需加载引擎
lazy.load({
  event = { 'User', pattern = 'VeryLazy' },
  setup = function()
    set_keys(key)

    _G.dd = function(...) Snacks.debug.inspect(...) end
    if utils.is_compatible_version('0.11') then
      ---@diagnostic disable-next-line: duplicate-set-field
      vim._print = function(_, ...) dd(...) end
    else
      vim.print = _G.dd
    end

    -- 切换器快捷键保留
    Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>us')
    Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
    Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map('<leader>uL')
    Snacks.toggle.diagnostics():map('<leader>ud')
    Snacks.toggle.line_number():map('<leader>ul')
    Snacks.toggle.option('conceallevel',
      { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map('<leader>uc')
    Snacks.toggle.treesitter():map('<leader>uT')
    Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map(
      '<leader>uB')
    Snacks.toggle.inlay_hints():map('<leader>uh')
    Snacks.toggle.indent():map('<leader>ug')
    Snacks.toggle.dim():map('<leader>uD')
  end
})

return Snacks
