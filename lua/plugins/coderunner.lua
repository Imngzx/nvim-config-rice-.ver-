-- ====================================================================
-- ⚡ CONFIGURATION SWITCHES (Set these at the top)
-- ====================================================================

-- Execution window mode: "float", "tab", or "term"
local RUNNER_MODE = 1
-- C build type: 1 = Release (GCC -O2); 2 = Debug (Clang -g -fsanitize) NOTE:: Only available on UNIX
local C_BUILD_TYPE = 2
-- C++ build type: 1 = Release (G++ -O2); 2 = Debug (Clang++ -g -fsanitize) NOTE:: Only available on UNIX
local CPP_BUILD_TYPE = 2

-- ====================================================================
-- ⚙️ HELPER FUNCTIONS
-- ====================================================================

local function get_mode()
  -- Using the local RUNNER_MODE variable defined above
  if RUNNER_MODE == 1 then
    return 'float'
  elseif RUNNER_MODE == 2 then
    return 'tab'
  elseif RUNNER_MODE == 3 then
    return 'term'
  else
    return 'float' -- Default if RUNNER_MODE is set incorrectly
  end
end

local function get_c_mode()
  if C_BUILD_TYPE == 1 then
    -- Release Build (GCC -O2)
    return {
      'cd $dir &&',
      'mkdir -p out &&',
      -- "gcc -Wall -Wextra -O2 -o out/$fileNameWithoutExt $fileName -lm &&",
      'gcc -Wall -Wextra -O2 -o out/$fileNameWithoutExt $fileName -lm -lraylib &&',
      './out/$fileNameWithoutExt',
    }
  else
    -- Debug Build (Clang -g -fsanitize)
    return {
      'cd $dir &&',
      'mkdir -p out &&',
      -- "clang -Wall -Wextra -g -fsanitize=address,undefined -o out/$fileNameWithoutExt $fileName -lm &&",
      'clang -Wall -Wextra -g -fsanitize=address,undefined -o out/$fileNameWithoutExt $fileName -lm -lraylib &&',
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
      -- "g++ -std=c++23 -Wall -Wextra -O2 -o out/$fileNameWithoutExt $fileName &&",
      'g++ -std=c++23 -Wall -Wextra -O2 -o out/$fileNameWithoutExt $fileName -lm -lraylib &&',
      './out/$fileNameWithoutExt',
    }
  else
    -- Debug Build (Clang++ -g -fsanitize)
    return {
      'cd $dir &&',
      'mkdir -p out &&',
      -- "clang++ -std=c++23 -Wall -Wextra -g -fsanitize=address,undefined -o out/$fileNameWithoutExt $fileName -lm &&",
      'clang++ -std=c++23 -Wall -Wextra -g -fsanitize=address,undefined -o out/$fileNameWithoutExt $fileName -lm -lraylib &&',
      './out/$fileNameWithoutExt',
    }
  end
end

-- ====================================================================
-- 💻 OS DETECTION AND FINAL CONFIG
-- ====================================================================

-- Detect OS
local is_windows = vim.uv.os_uname().sysname:match('Windows')

-- compiler configs
local filetype = {}

if is_windows then
  filetype = {
    cpp = {
      -- MSVC CL on Windows (unchanged)
      'cd $dir && cl /utf-8 /nologo /EHsc /O2 /std:c++latest /Zc:__cplusplus $fileName /Fe:$fileNameWithoutExt.exe && $fileNameWithoutExt.exe',
    },

    c = {
      -- MSVC CL on Windows (unchanged)
      'cd $dir && cl /utf-8 /nologo /O2 $fileName /Fe:$fileNameWithoutExt.exe && $fileNameWithoutExt.exe',
    },

    python = {
      'cd $dir &&',
      'python -u $fileName',
    },

    java = {
      'cd $dir; javac $fileName; java $fileNameWithoutExt',
    },

    rust = {
      'cd $dir; rustc $fileName; .\\$fileNameWithoutExt.exe',
    },

    typescript = {
      'deno run $fileName',
    },

    zig = {
      'cd $dir &&',
      'zig build run',
      -- "cd $dir; zig build-exe $fileName -O ReleaseSafe -o $fileNameWithoutExt.exe; .\\$fileNameWithoutExt.exe",
    },
  }
else
  filetype = {
    c = get_c_mode(),

    cpp = get_cpp_mode(),

    python = {
      'cd $dir &&',
      'python3 -u $fileName',
    },

    java = {
      'cd $dir &&',
      'javac $fileName &&',
      'java $fileNameWithoutExt',
    },

    rust = {
      'cd $dir &&',
      'rustc $fileName &&',
      './$fileNameWithoutExt',
    },

    typescript = {
      'deno run $fileName',
    },

    zig = {
      'cd $dir &&',
      'zig build run',
      -- "cd $dir && zig build-exe $fileName -O ReleaseSafe -femit-bin=$fileNameWithoutExt && ./$fileNameWithoutExt",
    },
  }
end

-- ====================================================================
-- 📦 VIM.PACK CONFIG (Converted)
-- ====================================================================
local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/CRAG666/code_runner.nvim',
  cmd = { 'RunCode', 'RunFile', 'RunProject', 'RunClose' },
  keys = {
    -- 💡 修复点：将带有 <cmd> 和 <CR> 的字符串，全部改写为安全的 Lua 函数
    { 'n', '<F5>', function()
      vim.cmd('w'); vim.cmd('RunCode')
    end, { desc = 'Save and Run Code' } },
    { 'n', '<S-F5>', function() vim.cmd('RunClose') end, { desc = 'Stop Running' } },
    { 'n', '<C-F5>', function()
      vim.cmd('w'); vim.cmd('RunFile')
    end, { desc = 'Save and Run File' } },
    { 'n', '<leader>rc', function()
      vim.cmd('w'); vim.cmd('RunCode')
    end, { desc = 'Save and Run Code' } },
    { 'n', '<leader>rf', function()
      vim.cmd('w'); vim.cmd('RunFile')
    end, { desc = 'Save and Run File' } },
    { 'n', '<leader>rp', function() vim.cmd('RunProject') end, { desc = 'Run Project' } },
    { 'n', '<leader>rx', function() vim.cmd('RunClose') end, { desc = 'Close Runner' } }, },
  setup = function()
    require('code_runner').setup({
      mode = get_mode(),
      focus = true,
      startinsert = true,
      term = { position = 'bot', size = 20 },
      float = {
        border = 'rounded',
        height = 0.8,
        width = 0.8,
        x = 0.5,
        y = 0.5,
        border_hl = 'FloatBorder',
        float_hl = 'Normal',
        blend = 0,
      },
      filetype = filetype,
    })
  end
})
