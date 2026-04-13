# Cameron's NeoVim Config *forked from CWorld 

> [!NOTE]
> This is a fork of the original [author's](https://github.com/cworld1/nvim-config) config. His config is the bone of my config. So please have a look on his config too.

> [!NOTE]
> nvim 0.12 & 0.13 have font issues with neovide, please use neovide-git instead.
>[issues between neovide and ui2](/note/ui2-issue.md) 

> [!WARNING]
> Please read the [disclaimer](/note/manifesto-%26-disclaimer.md) before copy or use this configuration
> This configuration is only for nvim version that starts from 0.12 to nightly

## About

This repository hosts my [NeoVim](https://neovim.io/) configuration for Desktop environment.

Use this on Linux for best experience ฅ₍^•⩊ •マⳊ

![Preview image](https://github.com/user-attachments/assets/7ccd5cec-e7a5-4ab7-8f54-f4597257d814)

| ![Preview image](https://github.com/user-attachments/assets/257edefa-7300-4343-8028-3ec1336d0272) | ![Preview image](https://github.com/user-attachments/assets/74629ff5-00e2-4728-a845-2e967d854359) |
| --------------------------------------------------------- | --------------------------------------------------------- |

| ![Preview image](https://github.com/user-attachments/assets/65f9696a-a535-454b-8623-3a93ab6e4c2f) | ![Preview image](https://github.com/user-attachments/assets/e5440088-cf1c-4455-9754-8768be3365c5) |
| --------------------------------------------------------- | --------------------------------------------------------- |


## Features

### Summarization
- **Fast.** Less than **50ms** to start, say no to heavy plugins for ui only 
- **Simple.** Run out of the box with only 31 life saving plugins.
- **Modern.** Pure `lua` config.
- **Modular.** Easy to customize.
- **Powerful.** Near full functionality to code.
- **Beautiful.** Uses catppuccin theme & good ui
- **Minimalist.** Plugins(DIY) with snacks integration

### Extras 

- List of features that became **Pluginless** 
    - [x] [incline.nvim](https://github.com/b0o/incline.nvim)
    - [x] [vim-suda](https://github.com/lambdalisue/vim-suda)
    - [x] [bufferline.nvim](github.com/akinsho/bufferline.nvim)
    - [x] [todo-comments](https://github.com/folke/todo-comments.nvim) (Key: `<Leader>st`)
    - [x] [fidget.nvim](https://github.com/j-hui/fidget.nvim) 
    - [x] [mini.surround](https://github.com/nvim-mini/mini.surround) 
    - [x] [mini.pairs](https://github.com/nvim-mini/mini.pairs?tab=readme-ov-file) 
    - [x] [aerial.nvim](https://github.com/stevearc/aerial.nvim) (Key: `<Leader>co`)
    - [x] [trouble.nvim](https://github.com/folke/trouble.nvim) (Key: `<Leader>cD`)
    - [x] [yazi.nvim](https://github.com/mikavilpas/yazi.nvim) (Key: `<Leader>fy`)
    - [x] [git-blame.nvim](https://github.com/f-person/git-blame.nvim.git) (Key: `<Leader>uB`)
    - [x] [persistence.nvim](https://github.com/folke/persistence.nvim) 
    - [x] [im-select.nvim](https://github.com/keaising/im-select.nvim) 


> [!TIP]
> Can test launch speed with:
```sh
❯ nvim --startuptime nvim_speed.log +q && nvim nvim_speed.log
# or
❯ PROF=1 nvim 

#NOTE: if you on windows, please:
❯ $env:PROF="1"; nvim # for pwsh

❯ set PROF=1 && nvim # for cmd
```

## Info

- Supported nvim version: `0.12 and above`
- Plugin manager: `vim.pack`
- Language server protocol: `nvim-lspconfig`
- Leader key: `Space`
- Default LSP for Lua-language: `lua_ls`
- Key doc: [Simple-keybinding-documentations](/note/simple-doc.md)

> [!NOTE]
> If you want to see the file structure of my config, please use `tree` in terminal

## Installation

Making sure you've installed [NeoVim-nightly 0.13](https://github.com/neovim/neovim/releases/nightly), tree-sitter-cli-git, and GCC on both Windows and Linux.

> [!TIP]
> Install tectonic for latex rendering, it is supported in this config

_For Windows:_

```bash
git clone https://github.com/Imngzx/nvim-config-rice-.ver-.git "${env:LOCALAPPDATA}\nvim"
nvim
```

_For \*nix:_

```bash
git clone https://github.com/Imngzx/nvim-config-rice-.ver-.git $XDG_CONFIG_HOME/nvim
nvim
```

After those steps above, please `<Leader>pm` to open Mason panel, it'll handle auto install as soon as you open it. 

Then please having fun!

## Project Structure

- `lua/config`: basic settings
- `lua/custom`: custom tools & functions
- `lua/libs`: shared libraries
- `lua/lsp`: LSP configuration for separate languages
- `lua/plugins`: plugin configurations
- `lua/lsp/init.lua`: simple lsp configurations
- `init.lua`: entry point

## Contributions

As the author is only a beginner in learning it, there are obvious mistakes in his notes. Readers are also invited to make a lot of mistakes. In addition, you are welcome to use PR or Issues to improve them.

## License

This project is licensed under the GPL 3.0 License.
