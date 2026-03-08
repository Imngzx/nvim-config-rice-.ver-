-- neovide will have fonts issues with nvim 0.12,
-- please use nvim 0.12.2 instead if you want to use neovide
if vim.g.neovide then
  vim.opt.guifont = { 'JetBrainsMono Nerd Font', ':h13' }
  -- vim.g.neovide_window_blurred = true
  -- vim.g.neovide_opacity = 0.93
  vim.g.neovide_floating_blur_amount_x = 3.0
  vim.g.neovide_floating_blur_amount_y = 3.0
  vim.g.neovide_refresh_rate = 240

  vim.g.neovide_cursor_antialiasing = true
  -- 光标闪烁动画
  vim.g.neovide_cursor_smooth_blink = true
  vim.opt.guicursor:append('a:blinkwait700-blinkon475-blinkoff475')

  vim.g.neovide_hide_titlebar = true
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_floating_shadow = false
  vim.g.neovide_window_blurred = true
  -- vim.g.neovide_opacity = 0.8
  -- vim.g.neovide_normal_opacity = 0.8
  if vim.g.neovide then
    -- Running in Neovide → disable snacks scroll
    vim.g.snacks_scroll = false
  else
    -- Running in terminal → enable snacks scroll
    vim.g.snacks_scroll = true
  end
end
