local M = {}

function M.setup()
	require("gitsigns").setup({
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			changedelete = { text = "~" },
		},
		signs_staged = {
			add = { text = "+" },
			change = { text = "~" },
			changedelete = { text = "~" },
		},
		signcolumn = true,
		numhl = true,
		linehl = true,
		word_diff = false,
		current_line_blame = true,
	})
end

return M
