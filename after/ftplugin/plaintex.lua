local plaintex_loaded = vim.b.plaintex_loaded

if plaintex_loaded then return end
plaintex_loaded = true

require('libs.spell')
