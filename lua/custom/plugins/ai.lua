return {
	-- GitHub Copilot
	"github/copilot.vim",
	event = "BufEnter",
	init = function()
		-- Disable Copilot's default Tab mapping so our custom mapping controls behavior.
		vim.g.copilot_no_tab_map = true
	end,
	config = function()
		require("custom.keymaps").setup_copilot_tab()
	end,
}
