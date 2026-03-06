# My Personal Neovim Configuration for Natively Running Neovim on any system 

A complete Neovim configuration that works out right after installing neovim on any system with a nerd font.

## 🎯 Quick Start

### VSCode Setup
**If you want to use my config inside VS Code instead of through the terminal only, switch to the `windows-vscode-with-neovim` branch via git to use the config tailored for using Neovim inside VSCode**

### To use Neovim with this config in your terminal

Just type `nvim` in your terminal - everything works automatically!

## ✨ Packages

- ✅ Package Manager used: lazy.nvim
- All packages are loaded inside the /lua/custom/plugins directory and each lua file is a plugin with any plugin specific info or keybindings.

## 🔑 Using Key Bindings

- In neovim, the `leader` key is defined per config and allows you to set custom commands after pressing it, most times it's set to the space bar key so that is what this config does too.
    - When you are in `n` (normal), clicking the space bar will show a menu through the 'which-key' plugin that shows you what options you have for commands. Commands may have subcommands after that too, so for example if you type 'space', 'c', 'a' sequentially, the 'space' initiates a command, then the 'c' means you want to do a 'code' type thing using your LSP, and the 'a' part specifies you want to see the code actions possible for the symbol under your cursor.

## 🔧 Configuration

- If you want to change anything in this config for your own setup, delete the `.git` folder from this configuration on your machine and init your own git repo for your config!
- Plugins can be deleted by just removing the file for a plugin from the /lua/custom/plugins directory.
- You can add a plugin by making a new file in that same directory and using lua, return the new plugin based on the lazy.nvim plugin specs.
    - Adding a plugin looks like this:
    ```lua
    return {
        "githubOwner/githubRepoName",
        lazy = INSERT_LAZY_LOADING_CHOICE_HERE
        opts = {} -- some plugins have some options you can put here
        config = function()
        -- Generally you can customize more configurations with lazy.nvim loaded plugins by add a custom config function for a plugin here, refer to the plugins docs for available options for the config
        end
    ```

## 🚀 Plugins

### Active Neovim Plugins that I use

- lazy.nvim - Plugin manager
- telescope.nvim - Fuzzy finder (PEAK NEOVIM)
- nvim-tree.lua - File explorer
- LSPConfig + Mason - Automatic language spec downloading 
    - Neovim doesnt automatically via your lsp config know all the syntax highlighting or code completion stuff without Mason. You will need this, I recommend you never delete this or the LSP Config.
- nvim-cmp - Useful for code completions, refactoring via code actions, code doc references, etc.
- And more, check /lua/custom/plugins, all lua files will be named according to purpose or the plugin name itself.

## 🤝 Contributing

Feel free to fork and adapt this configuration for your needs, but please don't contribute directly to this config. It's my personal configuration so use it if you like it but if you want to change something, copy this and make your own modifications on your own git repo :)

## 📄 License

MIT License - Use freely however you want!
