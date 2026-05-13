vim.opt.fileformats = "unix,dos,mac"
vim.opt.termguicolors = true
require("custom.plugins").setup()

vim.cmd.colorscheme("onedark")

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true -- If you can't run neovim its probably because you don't have a nerd font so set this to false or install one

vim.opt.number = true
vim.opt.showmode = true
vim.opt.swapfile = false

vim.o.autoindent = true
vim.o.smartindent = true
vim.o.smoothscroll = true

vim.opt.mouse = "a"

vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

require("custom.keymaps").setup()

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

require("custom.terminal").setup()
require("custom.lsp").setup()
require("custom.debugger").setup()
