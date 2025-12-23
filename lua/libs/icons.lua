local M = {}

M.get_icon_by_ext = function(ext)
  return M.ext[ext]
end

M.get_icon_by_ft = function(ft)
  return M.ft[ft]
end

M.get_icon_by_name = function(name)
  -- File
  if M.file[name] then return M.file[name] end
  local lower = name:lower()
  for k, v in pairs(M.file) do
    if k:lower() == lower then return v end
  end

  -- Filetype
  -- Prefer more ext (example: .tar.gz -> "tar.gz" then "gz")
  local parts = {}
  for part in name:gmatch("[^%.]+") do table.insert(parts, part) end
  if #parts > 1 then
    for i = 2, #parts do
      local ext = table.concat(parts, ".", i)
      if M.ext[ext] then return M.ext[ext] end
      if M.ft[ext] then return M.ft[ext] end
    end
  end

  -- Ext
  local ext = name:match("%.([^.]+)$")
  return M.get_icon_by_ext(ext)
end

-- [LSP]
M.lsp = {
  error = "E",
  warn = "W",
  hint = "H",
  info = "I",
}

-- [Filetype]
M.basic = {
  directory = "",
  file = "",
  modify = "●",
  close = "󰅖"
}
M.ft = {
  -- A
  astro       = "",
  asm         = "",
  -- B
  bash        = "",
  bib         = "",
  bin         = "",
  bat         = "",
  -- C
  c           = "",
  cpp         = "",
  cmake       = "",
  csharp      = "󰌛",
  -- D
  dart        = "",
  dockerfile  = "",
  -- E
  emacs       = "",
  elixir      = "",
  erlang      = "",
  -- F
  fsharp      = "",
  fortran     = "󱐋",
  fish        = "",
  -- G
  gitcommit   = "",
  gitconfig   = "",
  gitignore   = "",
  go          = "",
  graphql     = "",
  -- H
  html        = "",
  htm         = "",
  h           = "",
  -- I
  ini         = "",
  imagemagick = "",
  -- J
  java        = "",
  javascript  = "",
  json        = "",
  julia       = "",
  -- K
  kotlin      = "󱈙",
  -- L
  lua         = "",
  ledger      = "",
  latex       = "󰫹",
  -- M
  markdown    = "",
  make        = "",
  motif       = "",
  mustache    = "",
  -- N
  nginx       = "",
  nix         = "",
  -- O
  ocaml       = "λ",
  -- P
  perl        = "",
  php         = "",
  plaintext   = "",
  python      = "",
  -- R
  rust        = "",
  rb          = "",
  r           = "󰟔",
  sh          = "",
  zsh         = "",
  sql         = "",
  scss        = "",
  sass        = "",
  swift       = "",
  toml        = "",
  ts          = "",
  typescript  = "",
  tex         = "ﭨ",
  twig        = "",
  vim         = "",
  vue         = "󰡄",
  webpack     = "",
  xml         = "󰗀",
  xhtml       = "",
  xz          = "󰗄",
  yaml        = "",
}
M.file = {
  [".Dockerfile"]        = "",
  [".Dockerfile.dev"]    = "",
  [".Dockerfile.prod"]   = "",
  [".README.md"]         = "",
  [".Makefile"]          = "",
  [".babelrc"]           = "",
  [".babelrc.js"]        = "",
  [".bashrc"]            = "",
  [".compose"]           = "",
  [".dockerignore"]      = "",
  [".env"]               = "",
  [".env.example"]       = "",
  [".env.local"]         = "",
  [".editorconfig"]      = "",
  [".eslintrc"]          = "",
  [".eslintrc.js"]       = "",
  [".eslintrc.json"]     = "",
  [".eslintignore"]      = "",
  [".gitattributes"]     = "",
  [".gitconfig"]         = "",
  [".gitignore"]         = "",
  [".gitkeep"]           = "",
  [".gitmodules"]        = "",
  [".license"]           = "",
  [".npmignore"]         = "",
  [".npmrc"]             = "",
  [".package"]           = "",
  [".PACKAGE"]           = "",
  [".package-lock.json"] = "",
  [".package.json"]      = "",
  [".prettierrc"]        = "",
  [".prettierignore"]    = "",
  [".procfile"]          = "",
  [".readme"]            = "",
  [".tsconfig.json"]     = "",
  [".vscode"]            = "",
  [".vimrc"]             = "",
  [".webpack"]           = "",
  [".yarnrc"]            = "",
  [".yarnrc.yml"]        = "",
  [".nginx.conf"]        = "",

  LICENSE                = "󰿃",
  ["package.json"]       = "",
  ["package-lock.json"]  = "",
  ["yarn.lock"]          = "",
  ["pnpm-lock.yaml"]     = "",
}
M.ext = {
  -- Text / Markup
  txt                = "",
  md                 = "",
  markdown           = "",
  mdx                = "",
  rmd                = "",
  -- Code
  js                 = "",
  mjs                = "",
  cjs                = "",
  jsx                = "",
  ts                 = "",
  tsx                = "",
  py                 = "",
  rb                 = "",
  rs                 = "",
  go                 = "",
  java               = "",
  kt                 = "󱈙",
  kts                = "󱈙",
  swift              = "",
  cpp                = "",
  c                  = "",
  cs                 = "󰌛",
  php                = "",
  lua                = "",
  dart               = "",
  scala              = "",
  hs                 = "",
  erl                = "",
  ex                 = "",
  exs                = "",
  sh                 = "",
  bash               = "",
  zsh                = "",
  ps1                = "",
  vim                = "",
  ktlint             = "󱈙",
  -- Web
  html               = "",
  htm                = "",
  css                = "󰌜",
  scss               = "",
  less               = "",
  sass               = "",
  vue                = "󰡄",
  svelte             = "",
  xml                = "󰗀",
  xhtml              = "",
  json               = "",
  jsonc              = "",
  yaml               = "",
  yml                = "",
  ini                = "",
  -- Config / Dev
  Dockerfile         = "",
  dockerfile         = "",
  dockerignore       = "",
  env                = "",
  dotenv             = "",
  lock               = "",
  gradle             = "",
  Makefile           = "",
  makefile           = "",
  ["code-workspace"] = "",
  -- Data / DB
  sql                = "",
  sqlite             = "",
  csv                = "",
  toml               = "",
  plist              = "",
  -- Images
  png                = "",
  jpg                = "",
  jpeg               = "",
  gif                = "",
  webp               = "",
  svg                = "",
  ico                = "",
  -- Audio / Video
  mp3                = "",
  wav                = "",
  flac               = "",
  mp4                = "",
  mov                = "",
  mkv                = "",
  -- Archives / Binary
  zip                = "",
  tar                = "",
  ["tar.gz"]         = "",
  tgz                = "",
  gz                 = "",
  rar                = "",
  ["7z"]             = "",
  exe                = "",
  dll                = "",
  iso                = "",
  -- Docs / Office
  pdf                = "",
  doc                = "󱎒",
  docx               = "󱎒",
  xls                = "󱎏",
  xlsx               = "󱎏",
  ppt                = "󱎐",
  pptx               = "󱎐",
  -- Fonts
  ttf                = "",
  otf                = "",
  woff               = "",
  woff2              = "",
  -- Misc
  svgz               = "",
  psd                = "",
  ai                 = "",
}

return M
