-- neovim file explorer
return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy=false,
	cmd = { "NvimTreeToggle" },
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			-- Buffer-local mappings and small niceties for nvim-tree
			on_attach = function(bufnr)
				local api = require("nvim-tree.api")

				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				-- apply default mappings provided by nvim-tree
				if api and api.map and api.map.on_attach and api.map.on_attach.default then
					api.map.on_attach.default(bufnr)
				end

				-- common additional mappings (similar to NeoTree defaults)
				vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
				vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
				vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
				vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))
				vim.keymap.set("n", "t", api.node.open.tab, opts("Open: New Tab"))
				vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
				vim.keymap.set("n", "a", api.fs.create, opts("Create"))
				vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
				vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
				vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
				vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
				vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
				vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))
				vim.keymap.set("n", "<C-k>", api.node.show_info_popup, opts("Info"))
				vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
				-- Close tree with <Esc>
				vim.keymap.set("n", "<esc>", api.tree.close, opts("Close"))
			end,

			-- note: custom mappings are provided via `on_attach` above; do not use
			-- the deprecated `view.mappings` option which newer nvim-tree rejects.
		})
	end,
}

-- return {
--   "nvim-tree/nvim-tree.lua",
--   version = "*",
--   lazy = false,
--   dependencies = {
--     "nvim-tree/nvim-web-devicons",
--   },
--   config = function()
--     require("nvim-tree").setup {}
--   end,
-- }
