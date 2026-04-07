local lazy = require('libs.lazy')

lazy.load({
  plugin = { { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } },

  event = { 'BufReadPre', 'BufNewFile' },

  setup = function()
    if require('libs.utils').is_windows() then
      vim.env.CC = 'gcc'
      vim.env.CXX = 'g++'
    end

    local ts = require('nvim-treesitter')
    local parsers = {
      'c', 'cpp', 'python', 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline',
      'bash', 'json', 'yaml', 'toml', 'rust', 'zig', 'javascript', 'typescript', 'vue',
      'latex', 'html', 'regex', 'css',
    }

    ts.install(parsers, { summary = false })

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('TreesitterAttach', { clear = true }),
      callback = function(args)
        if vim.bo[args.buf].buftype ~= '' then return end

        if vim.b[args.buf].snacks_bigfile then
          return
        end

        local lang = vim.treesitter.language.get_lang(args.match)
        if lang then
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(args.buf) then
              local ok = pcall(vim.treesitter.start, args.buf, lang)
              if ok then
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
              end
            end
          end)
        end
      end,
    })
  end
})
