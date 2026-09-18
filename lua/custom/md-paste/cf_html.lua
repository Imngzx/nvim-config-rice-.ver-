local M = {}

local function literal(value)
  return (value:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', function(char)
    return '%' .. char
  end))
end

local start_fragment_marker = literal('<!--StartFragment-->')
local end_fragment_marker = literal('<!--EndFragment-->')

function M.parse(payload)
  if not payload or payload == '' then
    return nil, 'no-html'
  end

  local start_fragment = payload:match('StartFragment:(%d+)')
  local end_fragment = payload:match('EndFragment:(%d+)')
  local start_html = payload:match('StartHTML:(%d+)')
  local end_html = payload:match('EndHTML:(%d+)')

  local function extract(start_offset, end_offset)
    local start_index = tonumber(start_offset)
    local end_index = tonumber(end_offset)

    if not start_index or not end_index or end_index <= start_index then
      return nil
    end

    local first = math.max(start_index + 1, 1)

    if first > #payload then
      return nil
    end

    return payload:sub(first, math.min(end_index, #payload))
  end

  local fragment = extract(start_fragment, end_fragment)

  if fragment then
    fragment = fragment:gsub(start_fragment_marker, '', 1)
    fragment = fragment:gsub(end_fragment_marker, '', 1)

    if fragment ~= '' then
      return fragment, nil
    end
  end

  local html = extract(start_html, end_html)

  if html then
    return html, nil
  end

  if payload:match('^%s*<') then
    return payload, nil
  end

  return nil, 'no-html'
end

return M