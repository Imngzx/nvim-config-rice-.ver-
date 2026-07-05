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
date: 2026-07-05 14:11:26
tags: [[xxx]]
---

# Example

## Example Card

这是一张示例卡片。所有的原子笔记都应该像这样存放在 `Cards/` 目录下。
This is an example card. All atomic notes should be under `Cards/`

## Example Tags

这是一个关于tags的教程: [[🏷️-卡片盒标签使用指南]]

Links: [[index]]
]=]

local EXAMPLE_TAG_CONTENT = [=[
# 🏷️ 卡片盒标签使用指南

**卡片盒黄金法则**：
- **双向链接 (`[[xxx]]`)**：连接**逻辑与内容**（将相关笔记织成知识图谱）。
- **标签 (`tags: []`)**：管理笔记的**状态、类型或维度**（方便进行全局搜索和过滤）。

## 1. 状态管理标签（最推荐🌟）
卡片盒里的笔记是有“生命周期”的。你可以用标签来标记这篇笔记有多“成熟”：
- `seed`（种子）：刚写下一点想法，还没整理好，句子可能不通顺。（需后续加工）
- `incubator`（孵化中）：正在丰富完善中的笔记。
- `evergreen`（常青树）：已经写得非常完美、经得起时间考验的最终版原子笔记。
- `draft`（草稿）：还没写完的。
- `review`（待复习）：里面有个概念还没完全吃透，需要后续再看。

*写法示范：* `tags: [seed, review]`

## 2. 笔记类型标签（Type）
这篇笔记到底是什么？方便以后“只搜索我记过的所有Bug”：
- `concept`（概念解释）：比如讲什么是“闭包”、“所有权”。
- `bug-fix`（踩坑记录）：记录遇到什么报错，怎么解决的。
- `tutorial`（操作流程）：比如“如何配置 Nginx”。
- `quote`（金句摘录）：看书或看视频时摘抄的原话。
- `book-review`（读书笔记）。

*写法示范：* `tags: [bug-fix, backend]`

## 3. 行动上下文标签（Context）
结合 GTD (搞定系统)，标记信息在**什么场景下**使用：
- `work`（上班工作时需要查阅的）
- `life`（生活琐事、菜谱等）
- `to-read`（记录了一本书，但还没读）

*写法示范：* `tags: [work, to-read]`
]=]

local function get_workspace_root()
  local buf = api.nvim_get_current_buf()
  local root = fs.root(buf, { '.marksman.toml', '.git', 'Makefile', '.jj' }) or uv.cwd() or '.'
  return fs_normalize(root)
end

local function get_target_filepath(title, sub_dir)
  local timestamp = tostring(os.date('%Y%m%d%H%M'))
  local safe_title = title:gsub('%s+', '-'):gsub('[^%w%-一-龥]', ''):lower()
  local filename = timestamp .. '-' .. safe_title .. '.md'
  local root = get_workspace_root()
  local target_dir = fs_normalize(root .. '/' .. sub_dir)
  if not fs_stat(target_dir) then
    fn.mkdir(target_dir, 'p')
  end
  return target_dir .. '/' .. filename
end

local function createbuf_and_curpos(filepath, lines, cursor_pos)
  local bufnr = api.nvim_create_buf(true, false)
  api.nvim_buf_set_name(bufnr, filepath)
  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  api.nvim_set_option_value('filetype', 'markdown', { buf = bufnr })
  api.nvim_set_current_buf(bufnr)
  api.nvim_win_set_cursor(0, cursor_pos)
  -- uncomment this if you want insert mode after zettel init
  -- vim.cmd('startinsert')
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
        path .. '/Inbox/Daily',
        path .. '/Inbox/Meetings',
        path .. '/Inbox/Idea',
        path .. '/Inbox/Snippet',
        path .. '/Inbox/Projects',
        path .. '/Inbox/People',
        path .. '/Cards',
        path .. '/Cards/Examples',
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
      write_file(path .. '/Cards/Examples/example-card.md', EXAMPLE_CARD_CONTENT)
      write_file(path .. '/Cards/Examples/example-tag.md', EXAMPLE_TAG_CONTENT)
      vim.notify('\n[Zettel] Workspace initialized successfully at:\n' .. path, vim.log.levels.INFO)
      vim.cmd('edit ' .. fn.fnameescape(path .. '/index.md'))
    end)
  end)
end

function M.new_card()
  vim.ui.input({ prompt = ' 󰎚 Card Title: ' }, function(title)
    if not title or title == '' then return end
    vim.schedule(function()
      local filepath = get_target_filepath(title, 'Cards')
      local lines = {
        '---',
        'title: ' .. title,
        'date: ' .. tostring(os.date('%Y-%m-%d %H:%M:%S')),
        'tags: []',
        '---',
        '',
        '# ' .. title,
        '',
        'Links: [[index]]',
        'Tags Guide: [[🏷️-卡片盒标签使用指南]]',
      }
      createbuf_and_curpos(filepath, lines, { 7, 2 })
    end)
  end)
end

function M.new_inbox_note()
  local scenarios = {
    { name = '📝 Daily (日记/工作日志)', folder = 'Daily' },
    { name = '🤝 Meetings (会议记录)', folder = 'Meetings' },
    { name = '💡 Idea (灵感/随便写写)', folder = 'Idea' },
    { name = '✂️ Snippet (代码片段)', folder = 'Snippet' },
    { name = '📥 Root (直接扔进 Inbox 根目录)', folder = '' },
    { name = '📔 Projects (项目)', folder = 'Projects' },
    { name = '👀 People (关于人的)', folder = 'People' },
  }
  vim.ui.select(scenarios, {
    prompt = ' 📂 Select Scenario: ',
    format_item = function(item) return item.name end,
  }, function(choice)
    if not choice then return end
    local default_title = ''
    if choice.folder == 'Daily' then
      default_title = tostring(os.date('%Y-%m-%d'))
    end
    vim.schedule(function()
      vim.ui.input({ prompt = ' 󰎚 Note Title: ', default = default_title }, function(title)
        if not title or title == '' then return end
        vim.schedule(function()
          local subfolder = choice.folder == '' and 'Inbox' or ('Inbox/' .. choice.folder)
          local filepath = get_target_filepath(title, subfolder)
          local lines = {
            '---',
            'title: ' .. title,
            'date: ' .. tostring(os.date('%Y-%m-%d %H:%M:%S')),
            'scenario: ' .. (choice.folder == '' and 'Inbox' or choice.folder),
            '---',
            '',
            '# ' .. title,
            '',
          }
          createbuf_and_curpos(filepath, lines, { 7, 2 })
        end)
      end)
    end)
  end)
end

return M
