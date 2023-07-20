-- 设置 leader 键
vim.g.mapleader = " "

-- 单行或多行移动
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<M-k>", ":m '>-2<CR>gv=gv")

-- Whichkey
local whichkeymaps = {
  -- ----- Leader ----- --
  ["<leader>"] = { -- 指定该快捷键组的前缀
    name = "Leader", -- 指定该快捷键组的名称

    -- 文件操作
    c = { "<cmd>bd<cr>", "Close buffer"}, -- 关闭
    w = { "<cmd>w<cr>", "Save" }, -- 保存
    q = { "<cmd>q<cr>", "Quit" }, -- 退出
    -- 组合键
    ["wc"] = {"<cmd>w<cr><cmd>bd<cr>", "Save & close" },
    ["wq"] = {"<cmd>NvimTreeClose<cr><cmd>wq<cr>", "Save & quit" },

    -- 窗口
    s = {
      name = "Split window",
      v = { "<C-w>v", "Split right" }, -- 右侧新增窗口
      s = { "<C-w>s", "Split bottom" }, -- 底部新增窗口
    },
    ["`"] = { "<C-w>s <cmd>term<cr>", "Open terminal" }, -- 开辟终端窗口

    -- 代码状态
    x = { "<cmd>set invwrap<cr>", "Toggle wrap", noremap = true }, -- 切换是否自动换行
    n = { "<cmd>nohl<cr>", "Close search hl" },
    
    -- 插件
    -- Telescope
    f = {
      name = "Telescope",
      b = { "Find buffer" },
      f = { "Find file" },
      g = { "Find live grep" },
      h = { "Find help" },
      s = { "Find symbol" }
    },
    -- 返回主页 Dashboard
    h = { "<cmd>NvimTreeClose<cr><cmd>Dashboard<cr>", "Home" },
    -- 侧栏切换 NvimTree
    b = { "<cmd>NvimTreeToggle<cr>", "Sidebar" },
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
    -- Prettier
    p = { "<cmd>Prettier<cr><cmd>w<cr>", "Format" },
  },

  -- ----- Shift ----- --
  -- 标签页切换 Bufferline
  L = { "<cmd>BufferLineCycleNext<cr>", "Next buffer" },
  H = { "<cmd>BufferLineCyclePrev<cr>", "Previous buffer" },

  -- ----- Alt ----- --
  ["<M-j>"] = { "<cmd>m .+1<cr>==", "Move line down" }, -- 下移一行
  ["<M-k>"] = { "<cmd>m .-2<cr>==", "Move line up" }, -- 上移一行
}

return whichkeymaps
