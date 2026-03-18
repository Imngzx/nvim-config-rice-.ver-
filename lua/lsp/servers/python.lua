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
          diagnosticSeverityOverrides = {
            reportUnknownMemberType = 'none',
            reportUnknownArgumentType = 'none',
          },
          typeCheckingMode = 'basic',
          diagnosticMode = 'openFilesOnly',
          useLibraryCodeForTypes = true,
          inlayHints = {
            variableTypes = true,
            functionReturnTypes = true,
            callArgumentNames = true,
            pytestParameters = true,
          },
        },
      },
    },
    capabilities = {
      offsetEncoding = { 'utf-16' },
    },
  },
  ty = {
    -- NOTE: uv tool install ty
    mason = false,
    cmd = { 'ty', 'server' },
    capabilities = {
      offsetEncoding = { 'utf-16' },
    },
  }
}
