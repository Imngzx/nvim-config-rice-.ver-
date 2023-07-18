require("which-key").register ({
  f = {
      name = "Telescope", -- 指定该快捷键组的名称
      b = { "Find buffers" }, -- 创建新的快捷键绑定
      f = { "Find file" }, -- 创建新的快捷键绑定
      g = { "Find live grep" },
      h = { "Find help" }
  }
}, {prefix = "<leader>"})

require("which-key").setup()
