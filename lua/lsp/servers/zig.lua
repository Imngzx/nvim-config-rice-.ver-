---@module 'lspconfig'

return {
  mason = true,

  cmd = { 'zls' },

  ---@type lspconfig.settings.zls
  settings = {
    zls = {
      -- clean useless imports
      enable_autofix = true,
      warn_style = true,
    }
  }
}
