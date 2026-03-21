return {
  mason = false,

  cmd = { 'zls' },

  settings = {
    zls = {
      -- clean useless imports
      enable_autofix = true,
      warn_style = true,
    }
  }
}
