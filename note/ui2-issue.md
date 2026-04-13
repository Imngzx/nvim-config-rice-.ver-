[issue](https://github.com/neovide/neovide/issues/3446) 
[issue-reply](https://github.com/neovide/neovide/issues/3446#issuecomment-4233206735)

I made some small workaround to fix issue between neovide and ui2

In autocmds starts from line 5:

```lua
-- temporary ui2 fix on neovide
-- https://github.com/neovide/neovide/issues/3446#issuecomment-4233206735
vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = function()
    require('custom.ui2').setup()
  end
})
```

But there's still have issues between popup.nvim and neovide.
For instance, the cursor will be located on top left of neovim when entering command mode. But it acts very normal on almost every terminal
