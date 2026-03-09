vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--background-index',
    '-j=8', -- 并发数，根据你的 CPU 调整
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
})
