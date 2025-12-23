## Output

```lua
vim.print({ a = 1, b = 2 })        -- 推荐：自动漂亮格式化表/值（Neovim 内置）
vim.notify("hello", vim.log.levels.INFO) -- 带级别的通知
vim.api.nvim_out_write("hello\n")  -- 直接写到 stdout（不带换行需手动加）
print(vim.inspect(some_table))     -- print + inspect 格式化（需 require 'vim.inspect' 可用）
```

## Command

- `history`: check history commands
- `mes[sages]`: check the output messages of nvim
