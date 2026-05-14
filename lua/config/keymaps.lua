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
del("n", "<leader><space>")
del("n", "<leader>,")
del("n", "<leader>/")
del("n", "<leader>cd")
del("n", "<leader>gg")
del("n", "<leader>gG")
del("n", "<leader>l")
del("n", "<leader>sG")
del({ "n", "t" }, "<C-/>")
del_all("n", {
  "<leader>.",
  "<leader>:",
  "<leader>?",
  "<leader>S",
  "<leader>bP",
  "<leader>bj",
  "<leader>bl",
  "<leader>bp",
  "<leader>br",
  "<leader>n",
})
del({ "n", "t" }, "<C-_>")
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

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    del("n", "<leader>l")
    vim.keymap.set("n", "<leader>l", "<Nop>", { desc = "[L]azygit" })
  end,
})

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "[W]rite Buffer", nowait = true })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "[Q]uit Neovim" })
vim.keymap.set("n", "<leader>qb", function()
  Snacks.bufdelete()
end, { desc = "[Q]uit [B]uffer" })
vim.keymap.set("n", "<leader>e", function()
  Snacks.explorer({ cwd = LazyVim.root() })
end, { desc = "[E]xplorer" })
vim.keymap.set({ "n", "x" }, "<leader>f", function()
  LazyVim.format({ force = true })
end, { desc = "[F]ormat", nowait = true })
vim.keymap.set("n", "<leader>lg", function()
  if vim.fn.executable("lazygit") == 0 then
    vim.notify("lazygit is not installed", vim.log.levels.ERROR, { title = "LazyGit" })
    return
  end

  Snacks.lazygit({ cwd = LazyVim.root.git() })
end, { desc = "LazyGit" })
