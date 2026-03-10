# CWorld Neovim Config

> [!NOTE]
> This is a fork of the original [author's](https://github.com/cworld1/nvim-config)  config. His config is more focused on simplicity. Please have a look on his config too .

> [!NOTE]
> nvim 0.12 still have font issues with neovide, please use neovide-git instead

## About

This repo hosts my [NeoVim](https://neovim.io/) configuration for Desktop environment.

Use this on Linux for best experience

More photos can be found in [here](.github/assets) 

![Preview image](.github/assets/lsp-ui.png)

| ![Preview image](.github/assets/coderunner-support.png) | ![Preview image](.github/assets/new-key-hints-ui.png) |
| --------------------------------------------------------- | --------------------------------------------------------- |

| ![Preview image](.github/assets/rounded-corner-cmp.png) | ![Preview image](.github/assets/file-finding.png)  |

## Features

### Summarization
- **Fast.** Less than **50ms** to start on most of devices (Depends on SSD, CPU, and OS (**Linux** is suggested)).
- **Simple.** Run out of the box with only 25 plugins.
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
```

## Info

- Plugin manager: `vim.pack`
- Language server protocol: `nvim-lspconfig`
- Leader key: `Space`
- Default LSP for Lua-language: `lua_ls`

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
