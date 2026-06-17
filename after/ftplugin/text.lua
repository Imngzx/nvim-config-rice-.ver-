local text_loaded = vim.b.text_loaded

if text_loaded then return end
text_loaded = true

require('libs.spell')
