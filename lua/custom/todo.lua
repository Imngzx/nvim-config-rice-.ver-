-- nvim/lua/custom/todo.lua

-- 手搓版 Todo Comments
-- 利用底层 C 正则引擎，极速高亮，零性能损耗

local M = {}

-- 1. 配置标签和专属颜色 (完美契合 Catppuccin Mocha ☕)
local keywords = {
  TODO = '#a6e3a1', -- Mocha Green (待办/新功能)
  FIXME = '#f38ba8', -- Mocha Red (修 Bug)
  NOTE = '#89b4fa', -- Mocha Blue (笔记/记录)
  WARN = '#fab387', -- Mocha Peach (警告/注意)
  HACK = '#f9e2af', -- Mocha Yellow (临时硬编码/魔法)
  PERF = '#cba6f7', -- Mocha Mauve (性能优化)
}

function M.setup()
  local group = vim.api.nvim_create_augroup('HandcraftedTodo', { clear = true })

  -- 2. 动态生成底色高亮组
  local function set_hls()
    for kw, color in pairs(keywords) do
      -- 字体为深色，背景为设定颜色，加粗展示 (和原生 todo-comments 一模一样)
      vim.api.nvim_set_hl(0, 'HandcraftedTodo_' .. kw, { fg = '#181825', bg = color, bold = true })
    end
  end
  set_hls()
  -- 切换主题时自动重新应用
  vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = set_hls })

  -- 3. 核心：用 C 引擎直接捕获关键字
  vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
    group = group,
    callback = function()
      -- 👇 核心修复：必须【先无条件清理】当前窗口的旧匹配！
      -- 如果不这么做，当一个代码 Buffer 被切换成终端时，它会在下方的 return 被拦截，导致旧高亮永远残留在屏幕上。
      for _, m in ipairs(vim.fn.getmatches()) do
        if m.group:match('^HandcraftedTodo_') then
          pcall(vim.fn.matchdelete, m.id)
        end
      end

      -- 过滤掉悬浮窗、终端等非代码界面
      if vim.bo.buftype ~= '' then return end

      -- 遍历注入正则高亮
      for kw, _ in pairs(keywords) do
        -- 正则解释:
        -- \C 强制区分大小写 (必须全大写)
        -- \< 单词边界 (防止匹配到 "myTODO:")
        -- : 强制要求带冒号，防止误伤正常代码里的变量名
        pcall(vim.fn.matchadd, 'HandcraftedTodo_' .. kw, '\\C\\<' .. kw .. ':')
      end
    end
  })
end

-- 4. 梦幻联动：全项目搜索 TODO (调用 Snacks 引擎)
function M.search()
  local ok, snacks = pcall(require, 'snacks')
  if not ok then return end

  -- 自动拼接 ripgrep 正则，例如: \b(TODO|FIXME|NOTE|WARN|HACK|PERF):
  local kws = vim.tbl_keys(keywords)
  local search_pattern = '\\b(' .. table.concat(kws, '|') .. '):'

  snacks.picker.grep({
    title = 'Todo Comments',
    prompt = ' 󰄳  ',
    search = search_pattern,
    regex = true, -- 开启正则搜索
  })
end

return M
