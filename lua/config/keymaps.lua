-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function del(mode, lhs)
  pcall(vim.keymap.del, mode, lhs)
end

vim.keymap.set("n", "q", "<Nop>", { desc = "Disable macro recording" })

for _, lhs in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  vim.keymap.set({ "n", "i", "v", "x", "s", "o", "c" }, lhs, "<Nop>", { desc = "Disable arrow key" })
end

del("n", "<leader>qq")
del("n", "<leader>w")

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Write Buffer", nowait = true })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
vim.keymap.set("n", "<leader>qb", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
