-- 检查
local function list_capabilities(verbose)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_active_clients { bufnr = bufnr }
  -- TODO: ensure there is only one non null-ls LS and highlight '-' capabilities
  for _, client in pairs(clients) do
    if client.name ~= "null-ls" then
      if verbose then
        local content = vim.inspect(client.server_capabilities)
        vim.cmd("botright vnew")
        local new_bufnr = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_lines(
          new_bufnr,
          0,
          -1,
          true,
          vim.split(content, "\n", { plain = true, trimempty = false })
        )
        vim.bo[new_bufnr].buftype = "nofile"
        vim.bo[new_bufnr].filetype = "lua"
        vim.bo[new_bufnr].bufhidden = "wipe"
      else
        local caps = {}
        ---@param capability string
        ---@param info boolean
        for capability, info in pairs(client.server_capabilities) do
          if capability:find("Provider") then
            local capability_str = capability:gsub("Provider$", "")
            if info then
              table.insert(caps, "+ " .. capability_str)
            else
              table.insert(caps, "- " .. capability_str)
            end
          end
        end
        table.sort(caps)
        local msg = "# " .. client.name .. "\n" .. table.concat(caps, "\n")
        vim.notify(msg, vim.log.levels.INFO)
      end
    end
  end
end

local mycmd = vim.api.nvim_create_user_command
mycmd("LspCapabilities", function(info)
  list_capabilities(info.bang)
end, { bang = true })

