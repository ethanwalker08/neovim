return {
	"navarasu/onedark.nvim",
	priority = 1000, -- Ensure it loads first
	config = function()
		require("onedark").setup({
			code_style = {
				comments = "italic",
				variables = "bold",
				strings = "italic",
			},
			-- Additional options can be configured here
		})
		require("onedark").load()
	end,
}
