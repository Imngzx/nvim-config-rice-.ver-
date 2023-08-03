-- 透明化
-- https://github.com/xiyaowong/transparent.nvim
return {
  "xiyaowong/nvim-transparent",
  config = function()
    require("transparent").setup({
      groups = { -- table: default groups
                'Normal', 'NormalNC', 'Comment', 'Constant', 'Special',
                'Identifier','Statement', 'PreProc', 'Type','Underlined',
                'Todo', 'String', 'Function', 'Conditional', 'Repeat',
        'Operator', 'Structure', 'LineNr', 'NonText','SignColumn',
                'CursorLineNr', 'EndOfBuffer',
      },
            extra_groups = {
                'NeoTreeNormal', 'NeotreeNormalNC',
                'NeoTreeTabInactive', 'NeoTreeTabSeparatorInactive', 'NeoTreeTabSeparatorActive',
              }, -- table: additional groups that should be cleared
      exclude_groups = {}                                                                   -- table: groups you don't want to clear
    })

    vim.cmd('TransparentEnable')
  end
}
