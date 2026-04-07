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

function M.run()
  local ft = vim.bo.filetype
  local cmd_template = filetype_cmds[ft]

  if not cmd_template then
    vim.notify('No runner config for filetype: ' .. ft, vim.log.levels.WARN)
    return
  end

  local dir = vim.fn.expand('%:p:h')
  local fileName = vim.fn.expand('%:t')
  local fileNameWithoutExt = vim.fn.expand('%:t:r')

  local cmd = type(cmd_template) == 'table' and table.concat(cmd_template, ' ') or cmd_template
  cmd = cmd:gsub('%$dir', function() return dir end)
  cmd = cmd:gsub('%$fileNameWithoutExt', function() return fileNameWithoutExt end)
  cmd = cmd:gsub('%$fileName', function() return fileName end)

  execute_cmd(cmd)
end

function M.run_project()
  local cmd = ''
  if vim.fn.filereadable('Makefile') == 1 then
    cmd = 'make'
  elseif vim.fn.filereadable('Cargo.toml') == 1 then
    cmd = 'cargo run'
  elseif vim.fn.filereadable('build.zig') == 1 then
    cmd = 'zig build run'
  elseif vim.fn.filereadable('package.json') == 1 then
    cmd = 'npm start'
  else
    vim.notify('No project config found (Makefile/Cargo.toml/etc.)', vim.log.levels.WARN)
    return
  end
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
