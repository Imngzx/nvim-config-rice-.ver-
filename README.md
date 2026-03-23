# Cameron's NeoVim Config *forked from CWorld 

> [!NOTE]
> This is a fork of the original [author's](https://github.com/cworld1/nvim-config) config. His config is the bone of my config. So please have a look on his config too.

> [!NOTE]
> nvim 0.12 still have font issues with neovide, please use neovide-git instead

> [!WARNING]
> Please read the [disclaimer](/note/manifesto-%26-disclaimer.md) before copy or use this config  

## About

This repo hosts my [NeoVim](https://neovim.io/) configuration for Desktop environment.

Use this on Linux for best experience


![Preview image](https://github.com/user-attachments/assets/a2d65e96-0da7-4591-a646-f328792597ef)

| ![Preview image](https://github.com/user-attachments/assets/e71a29b2-397a-41a1-95db-fa798e9ec470) | ![Preview image](https://github.com/user-attachments/assets/a86f36ec-b477-40f0-9793-8b5a3c0336f0) |
| --------------------------------------------------------- | --------------------------------------------------------- |

| ![Preview image](https://github.com/user-attachments/assets/812c175f-fb38-4636-b9e3-14350fa0925e) | ![Preview image](https://github.com/user-attachments/assets/a0cda8a1-ca1f-434f-b7ea-7205f1088ec0) |
| --------------------------------------------------------- | --------------------------------------------------------- |


## Features

### Summarization
- **Fast.** Less than **50ms** to start 
- **Simple.** Run out of the box with only 28 plugins.
- **Modern.** Pure `lua` config.
- **Modular.** Easy to customize.
- **Powerful.** Near full functionality to code.
- **Beautiful.** Uses catppuccin theme
- **Minimalist.** Plugins(DIY) with snacks integration

### Extras 

- List of features that became **Pluginless** 
    - [x] [flash.nvim](https://github.com/folke/flash.nvim) (Key: `f`)
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

- Supported nvim version: `nightly 0.12`
- Plugin manager: `vim.pack`
- Language server protocol: `nvim-lspconfig`
- Leader key: `Space`
- Default LSP for Lua-language: `lua_ls`
- Key doc: [Simple-keybinding-documentations](/note/simple-doc.md)

> [!NOTE]
> If you want to see the file structure of my config, please use `tree` in terminal

## Installation

Making sure you've installed [NeoVim-nightly 0.12](https://github.com/neovim/neovim/releases/nightly), tree-sitter-cli, and GCC on both Windows and Linux.

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

After those steps above, please `<Leader>pm` to open Mason panel

Then please having fun!

## Project Structure

- `lua/config`: basic settings
- `lua/custom`: custom tools & functions
- `lua/libs`: shared libraries
- `lua/lsp`: LSP configuration for separate languages
- `lua/plugins`: plugin configurations
- `snippets/`: code snippets
- `init.lua`: entry point

## Contributions

As the author is only a beginner in learning it, there are obvious mistakes in his notes. Readers are also invited to make a lot of mistakes. In addition, you are welcome to use PR or Issues to improve them.

## License

This project is licensed under the GPL 3.0 License.
