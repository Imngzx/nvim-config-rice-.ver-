local lazy = require('libs.lazy')

-- [Treesitter] (基于最新 main 分支重构版)
lazy.load({
  -- 确保你拉取的是 main 分支的代码（如果是全新的电脑，这里很关键）
  plugin = { { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } },

  -- 依然使用文件触发，坚决不占启动时间
  event = { 'BufReadPre', 'BufNewFile' },

  setup = function()
    if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
      vim.env.CC = 'gcc' -- C 编译器
      vim.env.CXX = 'g++' -- C++ 编译器
    end

    local ts = require('nvim-treesitter')
    local parsers = {
      'c', 'cpp', 'python', 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline',
      'bash', 'json', 'yaml', 'toml', 'rust', 'zig', 'javascript', 'typescript', 'vue',
      'latex', 'html'
    }

    -- 异步安装 (如果是已安装的，这里瞬间跳过，0 损耗)
    ts.install(parsers, { summary = false })

    -- 👇 核心修复：用 Autocmd 动态监听，确保每个文件都能挂载！
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('TreesitterAttach', { clear = true }),
      callback = function(args)
        -- 👇 新增：使用底层 C API 获取文件大小（零 IO 阻塞）
        local file_name = vim.api.nvim_buf_get_name(args.buf)
        local stats = vim.uv.fs_stat(file_name)
        -- 如果文件大于 1.5MB，直接放弃挂载 Treesitter，保护内存！
        if stats and stats.size > 1.5 * 1024 * 1024 then
          vim.notify('大文件检测：已自动禁用 Treesitter 保护内存', vim.log.levels.WARN)
          return
        end

        local lang = vim.treesitter.language.get_lang(args.match)
        if lang then
          local ok = pcall(vim.treesitter.start, args.buf, lang)
          if ok then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end
      end,
    })
  end
})
