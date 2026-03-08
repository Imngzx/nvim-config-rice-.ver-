# CWorld Neovim Config

> [!NOTE]
> This is a fork of the original [author's](https://github.com/cworld1/nvim-config)  config. This config is more focused on UI and colors. Please have a look on his config too .

> [!NOTE]
> nvim 0.12 still have font issues with neovide, please use nvim 0.12.2 instead

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
- **Fast.** Less than **50ms** to start on most of devices (Depends on SSD and CPU).
- **Simple.** Run out of the box with only 25 plugins.
- **Modern.** Pure `lua` config.
- **Modular.** Easy to customize.
- **Powerful.** Near full functionality to code.
- **Beautiful.** Uses catppuccin mocha colorscheme

### Extras 
- **Pluginless** for flash, suda, and bufferline config

> [!TIP]
> you can press F for word jumping

## Info

- Plugin manager: `vim.pack`
- Language server protocol: `nvim-lspconfig`
- Leader key: `Space`

## Installation

Making sure you've installed [NeoVim](https://neovim.io/).

_For Windows:_

```bash
git clone https://github.com/Imngzx/linux-nvim-config2.git "${env:LOCALAPPDATA}\nvim"
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
- `lua/plugins`: plugin configurations
- `snippets/`: code snippets
- `init.lua`: entry point

## Contributions

As the author is only a beginner in learning it, there are obvious mistakes in his notes. Readers are also invited to make a lot of mistakes. In addition, you are welcome to use PR or Issues to improve them.

## License

This project is licensed under the GPL 3.0 License.
