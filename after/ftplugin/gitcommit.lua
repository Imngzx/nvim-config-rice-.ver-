local gitcommit_loaded = vim.b.gitcommit_loaded

if gitcommit_loaded then return end
gitcommit_loaded = true

require('libs.spell')
