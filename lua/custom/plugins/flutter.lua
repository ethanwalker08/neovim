return {
	{
		"nvim-flutter/flutter-tools.nvim",
		ft = { "dart" },
		cmd = {
			"FlutterRun",
			"FlutterDebug",
			"FlutterReload",
			"FlutterRestart",
			"FlutterQuit",
			"FlutterDevices",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"stevearc/dressing.nvim", -- optional for vim.ui.select
		},
		config = function()
			require("flutter-tools").setup({
				widget_guides = {
					enabled = true,
				},
				-- You can include other configuration options here
				debugger = {
					enabled = true,
					register_configurations = function(_)
						require("dap").configurations.dart = {}
						require("dap.ext.vscode").load_launchjs()
					end,
				},
			})
		end,
	},
}
