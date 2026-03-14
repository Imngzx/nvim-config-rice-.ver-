return {
  ruff = {
    capabilities = {
      general = {
        positionEncodings = { 'utf-16' },
      },
    },
    cmd_env = { RUFF_TRACE = 'messages' },
    init_options = {
      settings = {
        logLevel = 'error',
      },
    },
  },

  basedpyright = {
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = 'off',
        },
      },
    },
    capabilities = {
      offsetEncoding = { 'utf-16' },
    },
  }
}
