---@diagnostic disable: undefined-global

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "q", "<Nop>", { desc = "Disable macro recording" })

for _, lhs in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
	vim.keymap.set({ "n", "i", "v", "x", "s", "o", "c" }, lhs, "<Nop>", { desc = "Disable arrow key" })
end
