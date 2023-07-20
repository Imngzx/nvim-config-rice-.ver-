-- 设置 leader 键
vim.g.mapleader = " "

-- 单行或多行移动
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<M-k>", ":m '>-2<CR>gv=gv")

local whichkeymaps = {
  -- ----- Leader ----- --
  ["<leader>"] = { -- 指定该快捷键组的前缀
    name = "Leader", -- 指定该快捷键组的名称

    -- 文件操作
    w = { "<cmd>w<cr>", "Save" }, -- 保存
    q = { "<cmd>q<cr>", "Quit" }, -- 退出
    c = { "<cmd>bd<cr>", "Close buffer"},

    -- 窗口
    s = {
      name = "Split window",
      v = { "<C-w>v", "Split right" }, -- 右侧新增窗口
      s = { "<C-w>s", "Split bottom" }, -- 底部新增窗口
    },
    ["`"] = { "<C-w>s <cmd>term<cr>", "Open terminal" }, -- 开辟终端窗口

    -- 代码状态
    x = { "<cmd>set invwrap<cr>", "Toggle wrap",
    noremap = true }, -- 切换是否自动换行
    n = { "<cmd>nohl<cr>", "Cancel search highlight" },

    -- 插件
    -- Telescope
    f = {
        name = "Telescope",
        b = { "Find buffers" },
        f = { "Find file" },
        g = { "Find live grep" },
        h = { "Find help" },
        o = { "Find outlines" }
    },
    -- 返回主页 Dashboard
    h = { "<cmd>NvimTreeClose<cr><cmd>Dashboard<cr>", "Dashboard" },
    -- 侧栏切换 NvimTree
    b = { "<cmd>NvimTreeToggle<cr>", "NvimTree" },
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
