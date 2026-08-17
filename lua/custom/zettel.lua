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
local json_encode = vim.json.encode

local string_match = string.match
local string_gmatch = string.gmatch
local fn_substitute = fn.substitute
local string_gsub = string.gsub
local string_lower = string.lower
local fn_fnamemodify = fn.fnamemodify
local fn_fnameescape = fn.fnameescape
local fn_executable = fn.executable
local os_execute = os.execute
local os_date = os.date
local pcall = pcall
local tostring = tostring
local system = vim.system
local schedule = vim.schedule
local cwd = uv.cwd

local TOML_CONTENT = [=[
# .marksman.toml
[core]
markdown.extension = ".md"
]=]

local GITIGNORE = [=[
.meta/graph.html
]=]

local JSON_CONTENT = [=[
{
  "MD013": false,
  "MD060": false,
  "MD025": false
}
]=]

local EDITORCONFIG = [=[
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.lua]
max_line_length = 100
quote_style = single
continuation_indent = 2

table_separator_style = none
trailing_table_separator = keep
call_arg_parentheses = keep
end_statement_with_semicolon = keep

space_around_table_field_list = true
space_before_attribute = true
space_before_function_call_single_arg = always
space_before_inline_comment = 1
space_around_math_operator = true
space_around_concat_operator = true
space_around_logical_operator = true
space_around_assign_operator = true
space_after_comma = true
space_after_comma_in_for_statement = true

line_space_after_function_statement = fixed(2)
line_space_around_block = fixed(1)
]=]

local INDEX_CONTENT = [=[
# 🗂️ My Knowledge Base (MOC)

Welcome to your Zettelkasten!

## 📥 Inbox (待处理)

-

## 📚 Categories (索引)

- [[example-usage]] (👈 先看这里：使用说明书)
- [[example-card]]
]=]

local EXAMPLE_CARD_CONTENT = [=[
---
title: Example Card
date: 2026-07-05 14:11:26
tags: [example-tag]
---

# Example

## Example Card

这是一张示例卡片。所有的原子笔记都应该像这样存放在 `Cards/` 目录下。
This is an example card. All atomic notes should be under `Cards/`

## Example Tags

- 标签使用指南: [[example-tag]]
- 系统使用指南: [[example-usage]]

Links: [[index]]
]=]

local EXAMPLE_TAG_CONTENT = [=[
# 🏷️ 卡片盒标签使用指南 (Tag Usage Guide)

**卡片盒黄金法则 (Zettelkasten Golden Rules)**：

- **双向链接 (`[[]]`)**：连接**逻辑与内容**，将相关笔记织成知识图谱。 (Connects logic and content to weave a knowledge graph).
- **标签 (`tags: []`)**：管理笔记的**状态、类型或维度**，方便进行全局搜索和过滤。 (Manages the state, type, or context of notes for easy filtering).

## 1. 状态管理标签 (State Tags - Recommended🌟)

卡片盒里的笔记是有“生命周期”的。你可以用标签来标记这篇笔记有多“成熟”：
(Notes have a lifecycle. Use tags to mark their maturity):

- `seed`: 种子。刚写下一点想法，需后续加工。 (Raw thoughts, needs processing).
- `incubator`: 孵化中。正在丰富完善中的笔记。 (Work in progress).
- `evergreen`: 常青树。已经写得非常完美、经得起时间考验的最终版原子笔记。 (Polished, timeless atomic note).
- `draft`: 草稿。 (Draft).
- `review`: 待复习。里面有个概念还没完全吃透，需要后续再看。 (Needs review).

*写法示范 (Example):* `tags: [seed, review]`

## 2. 笔记类型标签 (Type Tags)

这篇笔记到底是什么？方便以后“只搜索我记过的所有Bug”：
(What is this note about? Useful for scoped searches):

- `concept`: 概念解释。 (Concept explanation, e.g., "Closure", "Ownership").
- `bug-fix`: 踩坑记录。遇到什么报错，怎么解决的。 (Bug fixing logs).
- `tutorial`: 操作流程。 (Step-by-step tutorials, e.g., "Nginx Config").
- `quote`: 金句摘录。 (Quotes from books/videos).
- `book-review`: 读书笔记。 (Book reviews).

*写法示范 (Example):* `tags: [bug-fix, backend]`

## 3. 行动上下文标签 (Context Tags)

结合 GTD (搞定系统)，标记信息在什么场景下使用：
(Based on GTD, mark when/where to use this info):

- `work`: 上班工作时需要查阅的。 (Work-related).
- `life`: 生活琐事、菜谱等。 (Life/Personal).
- `to-read`: 记录了一本书，但还没读。 (Reading list).

*写法示范 (Example):* `tags: [work, to-read]`
]=]

local EXAMPLE_USAGE_CONTENT = [=[
# 📖 Zettelkasten 使用说明书 (User Guide)

欢迎来到你的极速卡片盒笔记系统！
(Welcome to your lightning-fast Zettelkasten system!)

## 📂 目录结构与系统流 (Folder Structure & Workflow)

了解每个文件夹的作用，是维持知识库整洁的关键：
(Understanding the purpose of each folder is key to a tidy knowledge base):

- **`Inbox/` (收集箱)**: 任何未整理的想法、日记、会议记录、代码片段等，第一时间扔在这里，不要有心理负担。(Raw thoughts, daily logs, meeting notes, snippets go here first. Zero friction).
- **`Cards/` (卡片盒)**: 系统的核心。存放经过思考、提炼后的**原子笔记**。(The core. Stores atomic, evergreen notes).
  - *Workflow (工作流)*: 定期清理 Inbox，将有价值的内容提炼、重写后放入 Cards 目录。(Regularly process Inbox notes into Cards).
- **`Assets/` (资源)**: 存放所有图片和附件。(Store all images and attachments here).
- **`.meta/` (AI 脑)**: AI 助手的上下文配置。(AI assistant context files).

## 🚀 核心快捷键 (Hotkeys)

- `<leader>zI` : **初始化工作区 (Init Workspace)**。一键生成标准目录结构和 AI 元数据。(Generate standard directories and AI meta files).
- `<leader>zn` : **新建卡片 (New Card)**。
  - *闪电速记 (Quick Note)*: 弹出输入框时直接按 `Enter`，自动用时间戳命名并打开。(Press Enter to auto-generate timestamp filename).
  - *严谨记录 (Named Note)*: 输入标题（如 `Neovim API`），自动生成干净的 `neovim-api.md`。(Enter title for a clean filename).
- `<leader>zi` : **新建收集箱笔记 (New Inbox Note)**。分类记录 `Daily`, `Meetings` 等。日记会自动防重复！(Categorized quick captures. Daily notes are deduplicated).
- `<leader>zb` : **查找反向链接 (Find Backlinks)**。瞬间找出所有引用了当前笔记的卡片。(Instantly find all cards referencing the current note).

## 🔗 链接与标签 (Links & Tags)

- **双向链接 (Bi-directional Links)**: 输入 `[[` 触发补全（依赖 Marksman LSP）。(Type `[[` to trigger completion).
- **标签 (Tags)**: 在文件头部的 `tags: []` 处添加标签。详情请看 (See details in): [[example-tag]].

## 🤖 AI 联动 (AI Integration)

系统已自动生成了 `.meta/user.md` 和 `.meta/agent_rules.md`。在 CodeCompanion 聊天面板中可以 `@` 这些文件来提供上下文，让 AI 按照你的喜好和卡片盒里的内容回答问题！
(Mention these files in CodeCompanion chat to give AI context of your Zettelkasten!)
]=]

local USER_META_CONTENT = [=[
# 👤 User Profile (For AI Context)

- **Role**: Hacker / Developer
- **Preferences**:
  - 极客级性能追求者，喜欢 Neovim 且对代码性能有极致洁癖。
  - 给我写代码时，请使用最硬核的底层 API，绝对不允许冗余对象和 GC（垃圾回收）浪费。
  - 喜欢 Struct of Arrays (SoA) 和 Zero-Allocation 逻辑。
]=]

local AGENT_META_CONTENT = [=[
# 🤖 AI Agent Rules

- **Zettelkasten Context**: 回答问题时，请务必优先基于本 Workspace 内的卡片内容。
- **Formatting**: 熟练运用 Markdown 格式，输出清晰。
- **Style**: 专业、精准，不要为了寒暄浪费 Token。
]=]

-- ======== 🌌 Graph View HTML Templates ========
local GRAPH_TEMPLATE_HEAD = [=[
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Zettelkasten Graph</title>
  <style>
    body { margin: 0; padding: 0; background-color: #1e1e2e; font-family: 'Cascadia Code', monospace; overflow: hidden; }
    #graph { width: 100vw; height: 100vh; cursor: grab; }
    #graph:active { cursor: grabbing; }
    .hud { position: absolute; top: 15px; left: 20px; color: #a6adc8; z-index: 10; pointer-events: none; }
    h3 { margin: 0 0 5px 0; color: #cba6f7; text-transform: uppercase; letter-spacing: 2px; }
  </style>
  <script src="https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js"></script>
</head>
<body>
  <div class="hud"><h3>🌌 Zettel Graph</h3><span id="stats"></span></div>
  <div id="graph"></div>
  <script>
    const graphData =
]=]

local GRAPH_TEMPLATE_TAIL = [=[
    ;
    document.getElementById('stats').innerText = `Nodes: ${graphData.nodes.length} | Edges: ${graphData.links.length}`;
    const chart = echarts.init(document.getElementById('graph'));

    const nodeDegrees = {};
    graphData.links.forEach(l => {
      nodeDegrees[l.source] = (nodeDegrees[l.source] || 0) + 1;
      nodeDegrees[l.target] = (nodeDegrees[l.target] || 0) + 1;
    });

    graphData.nodes.forEach(n => {
      const degree = nodeDegrees[n.id] || 0;
      n.symbolSize = Math.max(10, Math.min(degree * 4 + 10, 40));
      n.itemStyle = {
         color: degree > 4 ? '#cba6f7' : (degree > 0 ? '#89b4fa' : '#a6adc8'),
         borderColor: '#11111b', borderWidth: 2
      };
      n.label = { show: degree > 0, color: '#cdd6f4', fontSize: 12 };
    });

    const option = {
      tooltip: {},
      series: [{
        type: 'graph',
        layout: 'force',
        data: graphData.nodes,
        links: graphData.links,
        roam: true,          // 开启滚轮缩放与平移
        draggable: true,     // 👈 修复：开启节点拖拽物理效果！
        label: { position: 'right' },
        force: { repulsion: 250, edgeLength: 80, gravity: 0.1, friction: 0.2 },
        lineStyle: { color: '#585b70', curveness: 0.1, width: 1.5 }
      }]
    };
    chart.setOption(option);
    window.addEventListener('resize', () => chart.resize());
  </script>
</body>
</html>
]=]

local function get_workspace_root()
  local buf = api.nvim_get_current_buf()
  local root = fs.root(buf, { '.marksman.toml', '.git', 'Makefile', '.jj' }) or cwd() or '.'
  return fs_normalize(root)
end

local function get_target_filepath(title, sub_dir, exact_name)
  local step1 = string_lower(string_gsub(title, '%s+', '-'))
  local safe_title = fn_substitute(step1, '\\v[^a-z0-9_.\\-一-龥ぁ-んァ-ヶ가-힣]', '', 'g')
  local filename = exact_name and (safe_title .. '.md') or
    (tostring(os_date('%Y%m%d%H%M')) .. '-' .. safe_title .. '.md')
  local root = get_workspace_root()
  local target_dir = fs_normalize(root .. '/' .. sub_dir)
  if not fs_stat(target_dir) then
    vim.fs.mkdir(target_dir, { parents = true })
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
    schedule(function()
      local home = os_homedir()
      if home and path:sub(1, 1) == '~' then
        path = home .. path:sub(2)
      end
      path = fs_normalize(path)
      local dirs = {
        path,
        path .. '/.meta',
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
          vim.fs.mkdir(dir, { parents = true })
        end
      end
      local function write_file(filepath, content)
        fs_stat(filepath, function(_, stat)
          if not stat then
            fs_open(filepath, 'w', 438, function(_, fd)
              if fd then
                fs_write(fd, content, -1, function()
                  fs_close(fd)
                end)
              end
            end)
          end
        end)
      end
      write_file(path .. '/.marksman.toml', TOML_CONTENT)
      write_file(path .. '/.markdownlint.json', JSON_CONTENT)
      write_file(path .. '/.editorconfig', EDITORCONFIG)
      write_file(path .. '/.gitignore', GITIGNORE)
      write_file(path .. '/index.md', INDEX_CONTENT)
      write_file(path .. '/Cards/Examples/example-card.md', EXAMPLE_CARD_CONTENT)
      write_file(path .. '/Cards/Examples/example-tag.md', EXAMPLE_TAG_CONTENT)
      write_file(path .. '/Cards/Examples/example-usage.md', EXAMPLE_USAGE_CONTENT)
      write_file(path .. '/.meta/user.md', USER_META_CONTENT)
      write_file(path .. '/.meta/agent_rules.md', AGENT_META_CONTENT)
      vim.notify('[Zettel] Workspace initialized successfully at:\n' .. path, vim.log.levels.INFO)
      vim.cmd('edit ' .. fn_fnameescape(path .. '/index.md'))
    end)
  end)
end

function M.new_card()
  vim.ui.input({ prompt = ' 󰎚 Card Title (Enter for Quick Note): ' }, function(title)
    if title == nil then return end
    schedule(function()
      local safe_input = vim.trim(title)
      local is_empty = (safe_input == '')
      local timestamp = tostring(os_date('%Y%m%d%H%M'))
      local filename_seed = is_empty and timestamp or title
      local final_title = is_empty and 'Untitled' or title
      local filepath = get_target_filepath(filename_seed, 'Cards', true)
      local lines = {
        '---',
        'title: ' .. final_title,
        'date: ' .. tostring(os.date('%Y-%m-%d %H:%M:%S')),
        'tags: []',
        '---',
        '',
        '# ' .. final_title,
        '',
        'Links: [[index]]',
        -- 'Tags Guide: [[example-tag]]',
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
    local is_daily = (choice.folder == 'Daily')
    local default_title = is_daily and tostring(os.date('%Y-%m-%d')) or ''

    schedule(function()
      vim.ui.input({ prompt = ' 󰎚 Note Title: ', default = default_title }, function(title)
        if not title or vim.trim(title) == '' then return end
        schedule(function()
          local subfolder = choice.folder == '' and 'Inbox' or ('Inbox/' .. choice.folder)
          local filepath = get_target_filepath(title, subfolder, is_daily)
          if is_daily and fs_stat(filepath) then
            vim.cmd('edit ' .. fn_fnameescape(filepath))
            vim.notify('󰎚 Daily note already exists. Opened.', vim.log.levels.INFO)
            return
          end
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

function M.backlinks()
  local ok, snacks = pcall(require, 'snacks')
  if not ok then return end
  local current_file = fn.expand('%:t:r')
  if current_file == '' then
    vim.notify('No file to find backlinks for!', vim.log.levels.WARN)
    return
  end
  local search_pattern = '\\[\\[' .. current_file .. '\\]\\]'
  snacks.picker.grep({
    title = ' 🔗 Backlinks (' .. current_file .. ') ',
    prompt = ' 󰌹  ',
    search = search_pattern,
    regex = true,
  })
end

local auto_graph_setup = false
--- @param silent boolean?
function M.generate_graph(silent)
  local root = get_workspace_root()
  if fn_executable('rg') == 0 then
    if not silent then
      vim.notify('[Zettel] "rg" (ripgrep) is required for graph view!',
        vim.log.levels.ERROR)
    end
    return
  end

  if not auto_graph_setup then
    auto_graph_setup = true
    api.nvim_create_autocmd('BufWritePost', {
      group = api.nvim_create_augroup('ZettelAutoGraph', { clear = true }),
      pattern = '*.md',
      callback = function(args)
        local file_path = api.nvim_buf_get_name(args.buf)
        if file_path:find(root, 1, true) then
          M.generate_graph(true) -- Silent update!
        end
      end
    })
  end

  local cmd = {
    'rg', '-o', '\\[\\[([^\\]]+)\\]\\]',
    '--vimgrep', '--no-heading',
    '-g', '*.md', '-g', '!{.meta,Assets,.*}/*',
    root
  }

  system(cmd, { text = true }, function(obj)
    schedule(function()
      if obj.code ~= 0 and obj.code ~= 1 then
        if not silent then
          vim.notify('[Zettel] Graph gen failed: ' .. (obj.stderr or 'error'),
            vim.log.levels.ERROR)
        end
        return
      end

      local output = obj.stdout or ''
      local nodes_map = {}
      local edge_map = {}
      local nodes = {}
      local links = {}
      local node_cnt = 0
      local link_cnt = 0

      for line in string_gmatch(output, '[^\r\n]+') do
        local file, target = string_match(line, '^(.-):%d+:%d+:%[%[(.-)%]%]$')
        if file and target then
          local source = fn_fnamemodify(file, ':t:r')
          if not nodes_map[source] then
            nodes_map[source] = true
            node_cnt = node_cnt + 1
            nodes[node_cnt] = { name = source, id = source }
          end
          if not nodes_map[target] then
            nodes_map[target] = true
            node_cnt = node_cnt + 1
            nodes[node_cnt] = { name = target, id = target }
          end
          local edge_key = source .. '\0' .. target
          if not edge_map[edge_key] then
            edge_map[edge_key] = true
            link_cnt = link_cnt + 1
            links[link_cnt] = { source = source, target = target }
          end
        end
      end

      local ok, json_str = pcall(json_encode, { nodes = nodes, links = links })
      if not ok then return end
      local html = GRAPH_TEMPLATE_HEAD .. json_str .. GRAPH_TEMPLATE_TAIL
      local html_path = root .. '/.meta/graph.html'
      fs_open(html_path, 'w', 438, function(_, fd)
        if fd then
          fs_write(fd, html, -1, function()
            fs_close(fd)
            if silent then return end
            schedule(function()
              if vim.ui.open then
                vim.ui.open(html_path)
              else
                local utils = require('libs.utils')
                local open_cmd = utils.is_mac() and 'open' or
                  (utils.is_windows() and 'start' or 'xdg-open')
                os_execute(open_cmd .. ' ' .. fn_fnameescape(html_path))
              end
              vim.notify(
                '🌌 Zettel Graph generated! (' ..
                node_cnt ..
                ' nodes)\n⚡ Auto-update enabled: Hit F5 in browser after saving your notes!',
                vim.log.levels.INFO)
            end)
          end)
        else
          if not silent then
            schedule(function()
              vim.notify('[Zettel] Failed to open graph HTML for writing', vim.log.levels.ERROR)
            end)
          end
        end
      end)
    end)
  end)
end

return M
