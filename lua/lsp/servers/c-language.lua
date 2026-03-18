return {
  mason = false, --NOTE: uncomment this to make mason install it
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--completion-style=detailed',
    '--function-arg-placeholders',
    '--fallback-style=llvm',
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
    fallbackFlags = {
      '--std=c++26',
      '/EHsc',
    },
  },
}
