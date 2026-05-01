local config = {}
function config.setup()
	require("copilot").setup({
		enabled = true,
		auto_refresh = true,
		should_attach = function(_, bufname)
			if string.match(bufname, "env") then
				return false
			end

			return true
		end,
		suggestion = {
			enabled = true,
			auto_trigger = true,
			hide_during_completion = true,
			keymap = {
				accept = false,
				dismiss = "<Esc>",
			},
		},
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "BlinkCmpMenuOpen",
		callback = function()
			vim.b.copilot_suggestion_hidden = true
			require("copilot.suggestion").toggle_auto_trigger()
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "BlinkCmpMenuClose",
		callback = function()
			vim.b.copilot_suggestion_hidden = false
			require("copilot.suggestion").toggle_auto_trigger()
		end,
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#83a598", italic = true })
			vim.api.nvim_set_hl(0, "CopilotAnnotation", { fg = "#83a598" })
		end,
	})
end

return config
