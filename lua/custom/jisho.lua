local M = {}

function M.search(word)
  if not word or word == '' then
    word = vim.fn.expand('<cword>')
  end

  word = vim.trim(word):gsub('%s+', ' ')

  if not word or word == '' then
    vim.notify('Please provide the Japanese word to query.！', vim.log.levels.WARN)
    return
  end

  vim.notify('Searching: ' .. word, vim.log.levels.INFO, { title = 'Jisho.org', id = 'jisho_req' })

  local url = 'https://jisho.org/api/v1/search/words'

  vim.system({ 'curl', '-s', '-G', '--data-urlencode', 'keyword=' .. word, url }, { text = true },
    function(obj)
      if obj.code ~= 0 or not obj.stdout then
        vim.schedule(function()
          vim.notify('API request failed, please check internet connection', vim.log.levels.ERROR,
            { title = 'Jisho.org' })
        end)
        return
      end

      local ok, parsed = pcall(vim.json.decode, obj.stdout)
      if not ok or not parsed or not parsed.data or #parsed.data == 0 then
        vim.schedule(function()
          vim.notify('Word not found: ' .. word, vim.log.levels.WARN, { title = 'Jisho.org' })
        end)
        return
      end

      local lines = {}
      for i = 1, math.min(5, #parsed.data) do
        local item = parsed.data[i]
        local jp = item.japanese[1]

        local word_jp = jp.word or jp.reading or 'Unknown'
        local reading = (jp.word and jp.reading) and (' *( ' .. jp.reading .. ' )*') or ''

        local is_common = item.is_common and ' `⭐ Common`' or ''
        local jlpt = (item.jlpt and #item.jlpt > 0) and (' `' .. string.upper(item.jlpt[1]) .. '`') or
          ''

        table.insert(lines, '## ' .. word_jp .. reading .. is_common .. jlpt)

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

      vim.schedule(function()
        vim.notify('Query successful', vim.log.levels.INFO,
          { title = 'Jisho.org', id = 'jisho_req', timeout = 10 })

        require('snacks').win({
          text = lines,
          width = 0.6,
          height = 0.7,
          border = 'rounded',
          title = ' 辞書 Jisho.org: ' .. word .. ' ',
          title_pos = 'center',
          bo = { filetype = 'markdown' },
          wo = {
            wrap = true,
            conceallevel = 2,
            number = true,
            numberwidth = 4,
            cursorline = true,
            relativenumber = true,
          },
          keys = {
            q = 'close', ['<Esc>'] = 'close',
          }
        })
      end)
    end)
end

return M
