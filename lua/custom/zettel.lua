local M = {}

local api = vim.api
local fn = vim.fn
local uv = vim.uv
local fs = vim.fs

local fs_stat = uv.fs_stat
local fs_open = uv.fs_open
local fs_write = uv.fs_write
local fs_close = uv.fs_close
local fs_normalize = fs.normalize
local os_homedir = uv.os_homedir

local TOML_CONTENT = [=[
# .marksman.toml
[core]
markdown.extension = ".md"
]=]

local INDEX_CONTENT = [=[
# 🗂️ My Knowledge Base (MOC)

Welcome to your Zettelkasten!

## 📥 Inbox (待处理)
-

## 📚 Categories (索引)
- [[example-card]]
]=]

local EXAMPLE_CARD_CONTENT = [=[
---
title: Example Card
date: ]=] .. os.date('%Y-%m-%d %H:%M:%S') .. [=[

tags: [example]
---

# Example Card

这是一张示例卡片。所有的原子笔记都应该像这样存放在 `Cards/` 目录下。

Links: [[index]]
]=]

local function get_workspace_root()
  local buf = api.nvim_get_current_buf()
  local root = fs.root(buf, { '.marksman.toml', '.git', 'Makefile', '.jj' }) or uv.cwd() or '.'
  return fs_normalize(root)
end

function M.init_workspace()
  local default_path = get_workspace_root()

  vim.ui.input({ prompt = ' 🚀 Init Zettel workspace in: ', default = default_path }, function(path)
    if not path or path == '' then return end

    vim.schedule(function()
      local home = os_homedir()
      if home and path:sub(1, 1) == '~' then
        path = home .. path:sub(2)
      end
      path = fs_normalize(path)

      local dirs = {
        path,
        path .. '/Inbox',
        path .. '/Cards',
        path .. '/Assets'
      }

      for i = 1, #dirs do
        local dir = dirs[i]
        if not fs_stat(dir) then
          fn.mkdir(dir, 'p')
        end
      end

      local function write_file(filepath, content)
        if not fs_stat(filepath) then
          local fd = fs_open(filepath, 'w', 438)
          if fd then
            fs_write(fd, content, -1)
            fs_close(fd)
          end
        end
      end

      write_file(path .. '/.marksman.toml', TOML_CONTENT)
      write_file(path .. '/index.md', INDEX_CONTENT)
      write_file(path .. '/Cards/example-card.md', EXAMPLE_CARD_CONTENT)

      vim.notify('\n[Zettel] Workspace initialized successfully at:\n' .. path, vim.log.levels.INFO)
      vim.cmd('edit ' .. fn.fnameescape(path .. '/index.md'))
    end)
  end)
end

function M.new_card()
  vim.ui.input({ prompt = ' 󰎚 Card Title: ' }, function(title)
    if not title or title == '' then return end

    vim.schedule(function()
      local timestamp = os.date('%Y%m%d%H%M')
      local safe_title = title:gsub('%s+', '-'):gsub('[^%w%-一-龥]', ''):lower()
      local filename = timestamp .. '-' .. safe_title .. '.md'

      local root = get_workspace_root()
      local target_dir = fs_normalize(root .. '/Cards')

      if not fs_stat(target_dir) then
        fn.mkdir(target_dir, 'p')
      end

      local filepath = target_dir .. '/' .. filename

      local lines = {
        '---',
        'title: ' .. title,
        'date: ' .. os.date('%Y-%m-%d %H:%M:%S'),
        'tags: []',
        '---',
        '',
        '# ' .. title,
        '',
        'Links: [[index]]',
      }

      local bufnr = api.nvim_create_buf(true, false)

      api.nvim_buf_set_name(bufnr, filepath)
      api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      api.nvim_set_option_value('filetype', 'markdown', { buf = bufnr })

      api.nvim_set_current_buf(bufnr)

      api.nvim_win_set_cursor(0, { 7, 2 })
    end)
  end)
end

return M
