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
			window = {
				mappings = {
					["<esc>"] = "close_window",
				},
			},
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
