return { -- Useful plugin to show you pending keybinds.
	"folke/which-key.nvim",
	event = "VimEnter", -- Sets the loading event to 'VimEnter'
	opts = {
		icons = {
			-- set icon mappings to true if you have a Nerd Font
			mappings = vim.g.have_nerd_font,
		},
		spec = require("custom.keymaps").which_key_groups(),
	},
	config = function(_, opts)
		require("which-key").setup(opts)
		require("custom.keymaps").setup_which_key_navigation()
	end,
}
