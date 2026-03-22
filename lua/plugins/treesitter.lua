local lazy = require('libs.lazy')

-- [Treesitter] (基于最新 main 分支重构版)
lazy.load({
  -- 确保你拉取的是 main 分支的代码（如果是全新的电脑，这里很关键）
  plugin = { { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } },

  -- 依然使用文件触发，坚决不占启动时间
  event = { 'BufReadPre', 'BufNewFile' },

  setup = function()
    if require('libs.utils').is_windows() then
      vim.env.CC = 'gcc' -- C 编译器
      vim.env.CXX = 'g++' -- C++ 编译器
    end

    local ts = require('nvim-treesitter')
    local parsers = {
      'c', 'cpp', 'python', 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline',
      'bash', 'json', 'yaml', 'toml', 'rust', 'zig', 'javascript', 'typescript', 'vue',
      'latex', 'html', 'regex',
    }

    -- 异步安装 (如果是已安装的，这里瞬间跳过，0 损耗)
    ts.install(parsers, { summary = false })

    -- 👇 核心修复：用 Autocmd 动态监听，确保每个文件都能挂载！
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('TreesitterAttach', { clear = true }),
      callback = function(args)
        -- 👇 修复 1：绝对禁止为 Snacks 预览框、终端、AI 聊天框等特殊 Buffer 挂载全局 TS！
        -- 它们要么有自己的渲染引擎，要么不需要庞大的 AST 语法树。
        if vim.bo[args.buf].buftype ~= '' then return end

        -- 👇 使用底层 C API 获取文件大小
        local file_name = vim.api.nvim_buf_get_name(args.buf)
        if file_name ~= '' then
          local stats = vim.uv.fs_stat(file_name)
          if stats and stats.size > 1.5 * 1024 * 1024 then
            vim.notify('Big file detected: Disabled treesitter for memory safety',
              vim.log.levels.WARN)
            return
          end
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
