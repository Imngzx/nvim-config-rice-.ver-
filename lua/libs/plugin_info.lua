local M = {}

function M.get_info()
  local pack_dir = vim.fs.normalize(vim.fn.stdpath('data') .. '/site/pack')
  local plugins = {}
  local loaded_set = {}
  local loaded_count = 0
  local total_count = 0

  -- 1. 抓取当前已加载的路径
  for _, p in ipairs(vim.api.nvim_list_runtime_paths()) do
    loaded_set[vim.fs.normalize(p)] = true
  end

  -- 2. 扫描硬盘里的包
  if vim.fn.isdirectory(pack_dir) == 1 then
    for pkg_name, pkg_type in vim.fs.dir(pack_dir) do
      if pkg_type == 'directory' then
        for _, sub in ipairs({ 'start', 'opt' }) do
          local target_dir = pack_dir .. '/' .. pkg_name .. '/' .. sub
          if vim.fn.isdirectory(target_dir) == 1 then
            for plugin_name, p_type in vim.fs.dir(target_dir) do
              if p_type == 'directory' then
                total_count = total_count + 1
                local p_path = target_dir .. '/' .. plugin_name
                local is_loaded = loaded_set[p_path] or false

                if is_loaded then
                  loaded_count = loaded_count + 1
                end

                table.insert(plugins, {
                  name = plugin_name,
                  type = sub,
                  path = p_path,
                  loaded = is_loaded,
                })
              end
            end
          end
        end
      end
    end
  end

  -- 3. 排序：已加载的在前，按字母顺序排
  table.sort(plugins, function(a, b)
    if a.loaded ~= b.loaded then return a.loaded end
    return a.name:lower() < b.name:lower()
  end)

  return {
    plugins = plugins,
    total = total_count,
    loaded = loaded_count,
  }
end

return M
