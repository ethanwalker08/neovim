-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function del(mode, lhs)
  pcall(vim.keymap.del, mode, lhs)
end

local function del_all(mode, mappings)
  for _, lhs in ipairs(mappings) do
    del(mode, lhs)
  end
end

vim.keymap.set("n", "q", "<Nop>", { desc = "Disable macro recording" })

for _, lhs in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  vim.keymap.set({ "n", "i", "v", "x", "s", "o", "c" }, lhs, "<Nop>", { desc = "Disable arrow key" })
end

del("n", "<leader>qq")
del("n", "<leader>w")
del("n", "<leader>e")
del("n", "<leader>E")
del("n", "<leader>gg")
del("n", "<leader>gG")
del_all("n", {
  "<leader>f",
  "<leader>fb",
  "<leader>fB",
  "<leader>fc",
  "<leader>fe",
  "<leader>fE",
  "<leader>ff",
  "<leader>fF",
  "<leader>fg",
  "<leader>fn",
  "<leader>fp",
  "<leader>fr",
  "<leader>fR",
  "<leader>ft",
  "<leader>fT",
})

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Write Buffer", nowait = true })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
vim.keymap.set("n", "<leader>qb", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>e", function()
  Snacks.explorer({ cwd = LazyVim.root() })
end, { desc = "Explorer" })
vim.keymap.set("n", "<leader>E", function()
  Snacks.explorer()
end, { desc = "Explorer (cwd)" })
vim.keymap.set("n", "<leader>lg", function()
  if vim.fn.executable("lazygit") == 0 then
    vim.notify("lazygit is not installed", vim.log.levels.ERROR, { title = "LazyGit" })
    return
  end

  Snacks.lazygit({ cwd = LazyVim.root.git() })
end, { desc = "LazyGit" })
vim.keymap.set({ "n", "x" }, "<leader>f", function()
  LazyVim.format({ force = true })
end, { desc = "Format", nowait = true })

pcall(function()
  require("which-key").add({
    { "<leader>e", desc = "Explorer" },
    { "<leader>f", desc = "Format" },
    { "<leader>lg", desc = "LazyGit" },
  })
end)
