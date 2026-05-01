local M = {}

function M.setup()
	require("barbar").setup({
		auto_hide = false,
		sidebar_filetypes = {
			NvimTree = true,
		},
		icons = {
			gitsigns = {
				added = { enabled = true, icon = "+" },
				changed = { enabled = true, icon = "~" },
				deleted = { enabled = true, icon = "-" },
			},
		},
	})
end

return M
