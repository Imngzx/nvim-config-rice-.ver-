local telescope = require('telescope.builtin')
local gs = package.loaded.gitsigns

-- Whichkey
local M = {}

-- Normal 模式
M.n = {
  -- ----- Leader ----- --
  ["<leader>"] = {   -- 指定该快捷键组的前缀
    name = "Leader", -- 指定该快捷键组的名称

    -- 文件操作
    b = { "<cmd>bp | bd #<cr>", "Close buffer" }, -- 关闭
    w = { "<cmd>w<cr>", "+Save" },         -- 保存
    q = { "<cmd>q<cr>", "+Quit" },         -- 退出
    -- 组合键
    ["wb"] = { "<cmd>w<cr><cmd>bp | bd #<cr>", "Save & close buffer" },
    ["wq"] = { "<cmd>wqa<cr>", "Save & quit" },
    ["qq"] = { "<cmd>qa<cr>", "Quit completely" },
    ["q!"] = { "<cmd>q!<cr>", "Quit Force" },

    -- 窗口
    s = {
      name = "Split window",
      v = { "<C-w>v", "Split right" },  -- 右侧新增窗口
      s = { "<C-w>s", "Split bottom" }, -- 底部新增窗口
    },
    ["`"] = {
      name = "Terminal",
      ["`"] = { "<cmd>Lspsaga term_toggle<cr>", "Toggle float terminal" },
      s = { "<C-w>s <cmd>term pwsh<cr>", "Open terminal split" }, -- 下半开辟终端窗口
    },
    -- 代码状态
    x = { "<cmd>set invwrap<cr>", "Toggle wrap", noremap = true }, -- 切换是否自动换行
    n = { "<cmd>nohl<cr>", "Close search hl" },

    -- 插件
    -- Telescope
    f = {
      name = "Telescope",
      b = { telescope.find_files, "Find buffer" },
      f = { telescope.live_grep, "Find file" },
      g = { telescope.buffers, "Find live grep" },
      h = { telescope.help_tags, "Find help" },
      s = { telescope.treesitter, "Find symbol" }
    },
    -- 返回主页 Dashboard
    h = { "<cmd>Neotree close<cr><cmd>Dashboard<cr>", "Home" },
    -- Git 操作 Fugitive
    g = {
      name = "Git",
      a = { gs.stage_buffer, "Git add" },
      c = {
        name = "Git commit",
        c = { "<cmd>Git commit<cr>", "Git commit" },
        a = { "<cmd>Git commit --amend<cr>", "Git commit amended" },
      },
      b = { "<cmd>Git blame<cr>", "Git blame" },
      d = { "<cmd>Gvdiffsplit<cr>", "Git diff" },
      l = { "<cmd>Gclog<cr>", "Git log" },
      p = {
        name = "Git push/pull",
        l = { "<cmd>Git pull<cr>", "Git pull" },
        s = { "<cmd>Git push<cr>", "Git push" },
      },
      s = { gs.stage_hunk, "Git stage hunk" },
      r = { gs.reset_hunk, "Git reset hunk" },
      g = { "<cmd>Git<cr>", "Git panel" },
    },
    -- LSP
    c = {
      name = "Code",
      c = { vim.lsp.buf.format, "Format" },
      d = { "<cmd>Lspsaga peek_definition<cr>", "Definition" },
      r = { "<cmd>Lspsaga rename<cr>", "Rename" },
      f = { "<cmd>Lspsaga finder<cr>", "Find" },
      h = { "<cmd>Lspsaga hover_doc<cr>", "Hover" },
      a = { "<cmd>Lspsaga code_action<cr>", "Actions" },
      i = { "<cmd>Lspsaga diagnostic_jump_next<cr>", "Info next" },
      I = { "<cmd>Lspsaga diagnostic_jump_prev<cr>", "Info prev" },
      p = { "<cmd>Lspsaga show_workspace_diagnostics<cr>", "Workspace problem" },
    },
    o = { "<cmd>Lspsaga outline<cr>", "Outline" },
    -- Transparent
    t = { "<cmd>TransparentToggle<cr>", "Transparent" },
  },


  -- 侧栏切换 NeoTree
  ["\\"] = { "<cmd>Neotree toggle<cr>", "Sidebar" },
  -- ----- Shift ----- --
  -- 标签页切换 Bufferline
  L = { "<cmd>BufferLineCycleNext<cr>", "Next buffer" },
  H = { "<cmd>BufferLineCyclePrev<cr>", "Previous buffer" },

  -- ----- Alt ----- --
  ["<M-j>"] = { "<cmd>m .+1<cr>==", "Move line down" }, -- 下移一行
  ["<M-k>"] = { "<cmd>m .-2<cr>==", "Move line up" },   -- 上移一行
}

-- Visual
M.v = {
  ["<leader>"] = {   -- 指定该快捷键组的前缀
    name = "Leader", -- 指定该快捷键组的名称
    g = {
      name = "Git",
      s = { function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, "Git stage selected" },
      u = { function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, "Undo stage selected" },
    }
    -- 单行或多行移动
  },
  ["<M-j>"] = { ":m '>+1<CR>gv=gv", "Move down" },
  ["<M-k>"] = { ":m '>-2<CR>gv=gv", "Move up" },
}

return M
