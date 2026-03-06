return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		local dapui = require("dapui")
		dapui.setup() -- Ensure DAP UI is set up
	end,
}
