local builtin = require('telescope.builtin')

-- Whichkey
local M = {
  -- ----- Leader ----- --
  ["<leader>"] = {   -- 指定该快捷键组的前缀
    name = "Leader", -- 指定该快捷键组的名称

    -- 文件操作
    b = { "<cmd>bd<cr>", "Close buffer" }, -- 关闭
    w = { "<cmd>w<cr>", "+Save" },         -- 保存
    q = { "<cmd>q<cr>", "+Quit" },         -- 退出
    -- 组合键
    ["wb"] = { "<cmd>w<cr><cmd>bd<cr>", "Save & close buffer" },
    ["wq"] = { "<cmd>wqa<cr>", "Save & quit" },
    ["qq"] = { "<cmd>qa<cr>", "Quit completely" },
    ["q!"] = { "<cmd>NvimTreeClose<cr><cmd>q!<cr>", "Quit Force" },

    -- 窗口
    s = {
      name = "Split window",
      v = { "<C-w>v", "Split right" },                        -- 右侧新增窗口
      s = { "<C-w>s", "Split bottom" },                       -- 底部新增窗口
    },
    ["`"] = {
      name = "Terminal",
      ["`"] = { "<cmd>Lspsaga term_toggle<cr>", "Toggle float terminal" },
      s = {"<C-w>s <cmd>term pwsh<cr>", "Open terminal split" }, -- 下半开辟终端窗口
    },
    -- 代码状态
    x = { "<cmd>set invwrap<cr>", "Toggle wrap", noremap = true }, -- 切换是否自动换行
    n = { "<cmd>nohl<cr>", "Close search hl" },

    -- 插件
    -- Telescope
    f = {
      name = "Telescope",
      b = { builtin.find_files, "Find buffer" },
      f = { builtin.live_grep, "Find file" },
      g = { builtin.buffers, "Find live grep" },
      h = { builtin.help_tags, "Find help" },
      s = { builtin.treesitter, "Find symbol" }
    },
    -- 返回主页 Dashboard
    h = { "<cmd>NvimTreeClose<cr><cmd>Dashboard<cr>", "Home" },
    -- 侧栏切换 NvimTree
    t = { "<cmd>NvimTreeToggle<cr>", "Sidebar" },
    -- Git 操作 Fugitive
    g = {
      name = "Git",
      a = { "<cmd>Gwrite<cr>", "Git add" },
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
      r = { "<cmd>Git reset<cr>", "Git reset" },
      s = { "<cmd>Git<cr>", "Git status" },
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
    },
    o = { "<cmd>Lspsaga outline<cr>", "Outline" },
  },

  -- ----- Shift ----- --
  -- 标签页切换 Bufferline
  L = { "<cmd>BufferLineCycleNext<cr>", "Next buffer" },
  H = { "<cmd>BufferLineCyclePrev<cr>", "Previous buffer" },

  -- ----- Alt ----- --
  ["<M-j>"] = { "<cmd>m .+1<cr>==", "Move line down" }, -- 下移一行
  ["<M-k>"] = { "<cmd>m .-2<cr>==", "Move line up" },   -- 上移一行
}

return M
