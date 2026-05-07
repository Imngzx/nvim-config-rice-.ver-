local M = {}
local utils = require('libs.utils')

-- ====================================================================
-- ⚡ CONFIGURATION SWITCHES
-- ====================================================================

-- C build type: 1 = Release (GCC -O2); 2 = Debug (Clang -g -fsanitize) NOTE: Only available on UNIX
local C_BUILD_TYPE = 2
-- C++ build type: 1 = Release (G++ -O2); 2 = Debug (Clang++ -g -fsanitize) NOTE: Only available on UNIX
local CPP_BUILD_TYPE = 2

-- ====================================================================
-- ⚙️ COMPILER HELPERS
-- ====================================================================

local function get_c_mode()
  if C_BUILD_TYPE == 1 then
    -- Release Build (GCC -O2)
    return {
      'cd $dir &&',
      'mkdir -p out &&',
      'gcc -Wall -Wextra -O2 -o out/$fileNameWithoutExt $fileName -lm &&',
      -- 'gcc -Wall -Wextra -O2 -o out/$fileNameWithoutExt $fileName -lm -lraylib &&',
      './out/$fileNameWithoutExt',
    }
  else
    -- Debug Build (Clang -g -fsanitize)
    return {
      'cd $dir &&',
      'mkdir -p out &&',
      'clang -Wall -Wextra -g -fsanitize=address,undefined -o out/$fileNameWithoutExt $fileName -lm &&',
      -- 'clang -Wall -Wextra -g -fsanitize=address,undefined -o out/$fileNameWithoutExt $fileName -lm -lraylib &&',
      './out/$fileNameWithoutExt',
    }
  end
end

local function get_cpp_mode()
  if CPP_BUILD_TYPE == 1 then
    -- Release Build (G++ -O2)
    return {
      'cd $dir &&',
      'mkdir -p out &&',
      'g++ -std=c++23 -Wall -Wextra -O2 -o out/$fileNameWithoutExt $fileName &&',
      -- 'g++ -std=c++23 -Wall -Wextra -O2 -o out/$fileNameWithoutExt $fileName -lm -lraylib &&',
      './out/$fileNameWithoutExt',
    }
  else
    -- Debug Build (Clang++ -g -fsanitize)
    return {
      'cd $dir &&',
      'mkdir -p out &&',
      'clang++ -std=c++23 -Wall -Wextra -g -fsanitize=address,undefined -o out/$fileNameWithoutExt $fileName -lm &&',
      -- 'clang++ -std=c++23 -Wall -Wextra -g -fsanitize=address,undefined -o out/$fileNameWithoutExt $fileName -lm -lraylib &&',
      './out/$fileNameWithoutExt',
    }
  end
end

-- ====================================================================
-- 💻 OS DETECTION AND FILETYPE CONFIG
-- ====================================================================

local filetype_cmds = {}

if utils.is_windows() then
  filetype_cmds = {
    cpp = { 'cd $dir && cl /utf-8 /nologo /EHsc /O2 /std:c++latest /Zc:__cplusplus $fileName /Fe:$fileNameWithoutExt.exe && $fileNameWithoutExt.exe' },
    c = { 'cd $dir && cl /utf-8 /nologo /O2 $fileName /Fe:$fileNameWithoutExt.exe && $fileNameWithoutExt.exe' },
    python = { 'cd $dir &&', 'python -u $fileName' },
    java = { 'cd $dir; javac $fileName; java $fileNameWithoutExt' },
    rust = { 'cd $dir; rustc $fileName; .\\$fileNameWithoutExt.exe' },
    typescript = { 'deno run $fileName' },
    zig = { 'cd $dir &&', 'zig build run' },
  }
else
  filetype_cmds = {
    c = get_c_mode(),
    cpp = get_cpp_mode(),
    python = { 'cd $dir &&', 'python3 -u $fileName' },
    java = { 'cd $dir &&', 'javac $fileName &&', 'java $fileNameWithoutExt' },
    rust = { 'cd $dir &&', 'rustc $fileName &&', './$fileNameWithoutExt' },
    typescript = { 'deno run $fileName' },
    zig = { 'cd $dir &&', 'zig build run' },
  }
end

-- ====================================================================
-- 🚀 CORE LOGIC (Powered by Snacks)
-- ====================================================================

local active_term = nil

local function shellescape(value)
  return vim.fn.shellescape(value)
end

local function normalize_path(path)
  return vim.fs.normalize(path):gsub('\\', '/'):gsub('/$', '')
end

local function find_upward(name, start_dir)
  local matches = vim.fs.find(name, { path = start_dir, upward = true })
  return matches[1]
end

local function relative_path(root, path)
  local normalized_root = normalize_path(root)
  local normalized_path = normalize_path(path)
  local prefix = normalized_root .. '/'

  if normalized_path:sub(1, #prefix) == prefix then
    return normalized_path:sub(#prefix + 1)
  end
end

local function find_cargo_bin_name(cargo_toml, file_path)
  local root = vim.fn.fnamemodify(cargo_toml, ':h')
  local rel = relative_path(root, file_path)
  if not rel then return nil end

  local block_name, block_path = nil, nil
  for _, line in ipairs(vim.fn.readfile(cargo_toml)) do
    local inline_name, inline_path = line:match('name%s*=%s*"([^"]+)".-path%s*=%s*"([^"]+)"')
    if not inline_name then
      inline_path, inline_name = line:match('path%s*=%s*"([^"]+)".-name%s*=%s*"([^"]+)"')
    end
    if inline_name and inline_path == rel then return inline_name end

    if line:match('^%s*%[%[') then
      block_name, block_path = nil, nil
    end

    block_name = line:match('^%s*name%s*=%s*"([^"]+)"') or block_name
    block_path = line:match('^%s*path%s*=%s*"([^"]+)"') or block_path
    if block_name and block_path == rel then return block_name end
  end
end

local function find_package_name(cargo_toml)
  local in_package = false
  for _, line in ipairs(vim.fn.readfile(cargo_toml)) do
    if line:match('^%s*%[package%]%s*$') then
      in_package = true
    elseif line:match('^%s*%[') then
      in_package = false
    elseif in_package then
      local name = line:match('^%s*name%s*=%s*"([^"]+)"')
      if name then return name end
    end
  end
end

local function infer_cargo_bin_name(cargo_toml, file_path)
  local root = vim.fn.fnamemodify(cargo_toml, ':h')
  local rel = relative_path(root, file_path)
  if not rel then return nil end

  local bin_name = rel:match('^src/bin/([^/]+)%.rs$')
    or rel:match('^src/bin/([^/]+)/main%.rs$')
  if bin_name then return bin_name end

  if rel == 'src/main.rs' then return find_package_name(cargo_toml) end
end

local function cargo_project_command()
  local file_path = vim.fn.expand('%:p')
  local start_dir = vim.fn.expand('%:p:h')
  local cargo_toml = find_upward('Cargo.toml', start_dir)
  if not cargo_toml then return nil end

  local root = vim.fn.fnamemodify(cargo_toml, ':h')
  if vim.bo.filetype ~= 'rust' then
    return 'cd ' .. shellescape(root) .. ' && cargo run'
  end

  local bin_name = find_cargo_bin_name(cargo_toml, file_path)
    or infer_cargo_bin_name(cargo_toml, file_path)
  if bin_name then
    return 'cd ' .. shellescape(root) .. ' && cargo run --bin ' .. shellescape(bin_name)
  end

  return 'cd ' .. shellescape(root) .. ' && cargo run'
end

function M.close()
  if active_term and active_term:valid() then
    active_term:close()
    active_term = nil
  end
end

local function execute_cmd(cmd)
  vim.cmd('silent! write')
  M.close()

  local pause_cmd = ''
  if utils.is_windows() then
    if vim.o.shell:match('pwsh') or vim.o.shell:match('powershell') then
      pause_cmd = ' ; pause'
    else
      pause_cmd = ' & pause'
    end
  else
    pause_cmd =
    ' ; echo ""; bash -c \'read -n 1 -s -r -p "Press any key to continue..."\' 2>/dev/null || read -p "Press ENTER to continue..."'
  end

  local final_cmd = cmd .. pause_cmd

  local win_opts = {
    position = 'float',
    width = 0.8,
    height = 0.8,
    border = 'rounded',
    backdrop = 60,
    title = ' / Code Runner ',
    title_pos = 'center',
    zindex = 45,
  }

  active_term = require('snacks').terminal(final_cmd, {
    win = win_opts,
    enter = true,
  })

  vim.cmd('startinsert')
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { buf = active_term.buf, nowait = true })
end

function M.build_run_command()
  local ft = vim.bo.filetype
  local cmd_template = filetype_cmds[ft]

  if not cmd_template then
    vim.notify('No runner config for filetype: ' .. ft, vim.log.levels.WARN)
    return nil
  end

  if ft == 'rust' then
    local cargo_cmd = cargo_project_command()
    if cargo_cmd then return cargo_cmd end
  end

  local dir = vim.fn.expand('%:p:h')
  local fileName = vim.fn.expand('%:t')
  local fileNameWithoutExt = vim.fn.expand('%:t:r')

  local cmd = type(cmd_template) == 'table' and table.concat(cmd_template, ' ') or cmd_template
  cmd = cmd:gsub('%$dir', function() return dir end)
  cmd = cmd:gsub('%$fileNameWithoutExt', function() return fileNameWithoutExt end)
  cmd = cmd:gsub('%$fileName', function() return fileName end)

  return cmd
end

function M.run()
  local cmd = M.build_run_command()
  if not cmd then return end

  execute_cmd(cmd)
end

function M.build_project_command()
  if vim.fn.filereadable('Makefile') == 1 then
    return 'make'
  end

  local cargo_cmd = cargo_project_command()
  if cargo_cmd then return cargo_cmd end

  if vim.fn.filereadable('build.zig') == 1 then return 'zig build run' end
  if vim.fn.filereadable('package.json') == 1 then return 'npm start' end

  vim.notify('No project config found (Makefile/Cargo.toml/etc.)', vim.log.levels.WARN)
end

function M.run_project()
  local cmd = M.build_project_command()
  if not cmd then return end

  execute_cmd(cmd)
end

function M.setup()
  vim.keymap.set('n', '<F5>', M.run, { desc = 'Save and Run Code' })
  vim.keymap.set('n', '<leader>rc', M.run, { desc = 'Save and Run Code' })

  vim.keymap.set('n', '<C-F5>', M.run, { desc = 'Save and Run File' })
  vim.keymap.set('n', '<leader>rf', M.run, { desc = 'Save and Run File' })

  vim.keymap.set('n', '<leader>rp', M.run_project, { desc = 'Run Project' })

  vim.keymap.set('n', '<S-F5>', M.close, { desc = 'Stop Running' })
  vim.keymap.set('n', '<leader>rx', M.close, { desc = 'Close Runner' })
end

return M
