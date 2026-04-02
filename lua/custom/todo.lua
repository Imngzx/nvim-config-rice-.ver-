-- nvim/lua/custom/todo.lua

local M = {}

-- 只需保留给 Snacks 全项目搜索用的关键字即可
local keywords = {
  'TODO', 'FIXME', 'NOTE', 'WARN', 'HACK', 'PERF'
}

-- 保留一个空的 setup 函数，防止 init.lua 报错
function M.setup()
  -- 高亮功能已经通过更现代的 Extmark 引擎集成到 plugins/mini-hipatterns.lua 中。
  -- 彻底干掉了原版 matchadd 带来的屏幕残留 Bug，性能拉满！
end

-- 梦幻联动：全项目搜索 TODO (调用 Snacks 引擎)
function M.search()
  local ok, snacks = pcall(require, 'snacks')
  if not ok then return end

  -- 自动拼接 ripgrep 正则，例如: \b(TODO|FIXME|NOTE|WARN|HACK|PERF):
  local search_pattern = '\\b(' .. table.concat(keywords, '|') .. '):'

  snacks.picker.grep({
    title = 'Todo Comments',
    prompt = ' 󰄳  ',
    search = search_pattern,
    regex = true, -- 开启正则搜索
  })
end

return M
