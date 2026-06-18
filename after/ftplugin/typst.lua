local typst_loaded = vim.b.typst_loaded

if typst_loaded then return end
typst_loaded = true

require('libs.spell').setup()
