# CWorld Neovim Config

> [!NOTE]
> This is a fork of the original [author's](https://github.com/cworld1/nvim-config)  config. His config is more focused on simplicity. Please have a look on his config too .

> [!NOTE]
> nvim 0.12 still have font issues with neovide, please use neovide-git instead

## About

This repo hosts my [NeoVim](https://neovim.io/) configuration for Desktop environment.

Use this on Linux for best experience

More photos can be found in [here](.github/assets) 

![Preview image](https://github.com/user-attachments/assets/a2d65e96-0da7-4591-a646-f328792597ef)

| ![Preview image](https://github.com/user-attachments/assets/e71a29b2-397a-41a1-95db-fa798e9ec470) | ![Preview image](https://github.com/user-attachments/assets/a86f36ec-b477-40f0-9793-8b5a3c0336f0) |
| --------------------------------------------------------- | --------------------------------------------------------- |

| ![Preview image](https://github.com/user-attachments/assets/812c175f-fb38-4636-b9e3-14350fa0925e) | ![Preview image](https://github.com/user-attachments/assets/a0cda8a1-ca1f-434f-b7ea-7205f1088ec0) |
| --------------------------------------------------------- | --------------------------------------------------------- |


## Features

### Summarization
- **Fast.** Less than **50ms** to start on most of devices (Depends on SSD, CPU, and OS (**Linux** is suggested)).
- **Simple.** Run out of the box with only 27 plugins.
- **Modern.** Pure `lua` config.
- **Modular.** Easy to customize.
- **Powerful.** Near full functionality to code.
- **Beautiful.** Uses catppuccin theme, deeply integrated with snacks.nvim

### Extras 

- **Pluginless** for flash, suda, incline, fidget and bufferline features

> [!TIP]
> you can press F for word jumping (folke flash)

> [!TIP]
> can test launch speed with 
```sh
❯ nvim --startuptime nvim_speed.log +q && nvim nvim_speed.log
# or
❯ PROF=1 nvim 

#NOTE: if you on windows, please:
❯ $env:PROF="1"; nvim # for pwsh

❯ set PROF=1 && nvim # for cmd
```

## Info

- Plugin manager: `vim.pack`
- Language server protocol: `nvim-lspconfig`
- Leader key: `Space`
- Default LSP for Lua-language: `lua_ls`
- Doc: [Simple-keybinding-documentations](/note/simple-doc.md)
- This is the [file structure](/note/file-structure.md) of my config.

## Installation

Making sure you've installed [NeoVim 0.12](https://github.com/neovim/neovim/releases/nightly), tree-sitter-cli, and GCC on both Windows and Linux.

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
