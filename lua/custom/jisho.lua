local M = {}

function M.search(word)
  -- 1. 智能获取要查询的词
  if not word or word == '' then
    word = vim.fn.expand('<cword>') -- 默认抓取光标下的词
  end

  if not word or word == '' then
    vim.notify('请提供要查询的日语单词！', vim.log.levels.WARN)
    return
  end

  -- Jisho.org 的官方免费开放 API
  local url = 'https://jisho.org/api/v1/search/words'

  -- 2. 使用 Nvim 0.10+ 原生异步 vim.system，后台静默请求，绝对不卡主线程
  vim.system({ 'curl', '-s', '-G', '--data-urlencode', 'keyword=' .. word, url }, { text = true },
    function(obj)
      if obj.code ~= 0 or not obj.stdout then
        vim.schedule(function() vim.notify('Jisho API 请求失败', vim.log.levels.ERROR) end)
        return
      end

      local ok, parsed = pcall(vim.json.decode, obj.stdout)
      if not ok or not parsed or not parsed.data or #parsed.data == 0 then
        vim.schedule(function() vim.notify('Jisho 未找到该词: ' .. word, vim.log.levels.WARN) end)
        return
      end

      -- 3. 用 Markdown 语法组装排版数据
      local lines = {}
      for i = 1, math.min(5, #parsed.data) do -- 提取前 5 个最匹配的词意
        local item = parsed.data[i]
        local jp = item.japanese[1]

        -- 处理有时只有假名没有汉字的情况
        local word_jp = jp.word or jp.reading
        local reading = (jp.word and jp.reading) and (' *( ' .. jp.reading .. ' )*') or ''

        local is_common = item.is_common and ' `⭐ Common`' or ''
        local jlpt = (item.jlpt and #item.jlpt > 0) and (' `' .. string.upper(item.jlpt[1]) .. '`') or
        ''

        -- 标题行：汉字 ( 假名 ) [JLPT级别]
        table.insert(lines, '## ' .. word_jp .. reading .. is_common .. jlpt)

        -- 意思解析行
        for j, sense in ipairs(item.senses) do
          local eng = table.concat(sense.english_definitions, ', ')
          local pos = ''
          if sense.parts_of_speech and #sense.parts_of_speech > 0 then
            pos = '`[' .. table.concat(sense.parts_of_speech, ', ') .. ']` '
          end
          table.insert(lines, '- **' .. j .. '.** ' .. pos .. eng)
        end
        table.insert(lines, '---')
      end

      -- 4. 召唤 Snacks 的极美圆角悬浮窗！
      vim.schedule(function()
        require('snacks').win({
          text = lines,
          width = 0.6,
          height = 0.7,
          border = 'rounded',
          title = ' 辞書 Jisho.org: ' .. word .. ' ',
          title_pos = 'center',
          bo = { filetype = 'markdown' }, -- 激活 render-markdown 渲染！
          wo = { wrap = true, conceallevel = 2 },
          keys = {
            q = 'close', ['<Esc>'] = 'close',
          }
        })
      end)
    end)
end

return M
