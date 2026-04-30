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
		suggestions = {
			enabled = true,
			auto_trigger = true,
			hide_during_completion = false,
			keymap = {
				-- Disable copilot's own <Tab> binding; we register it in VimEnter
				-- below so it is set after blink.cmp and takes priority.
				accept = false,
				dismiss = "<Esc>",
			},
		},
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "BlinkCmpMenuClose",
		callback = function()
			vim.b.copilot_suggestion_hidden = false
		end,
	})

	-- Register <Tab> after all plugins have loaded so this mapping wins over
	-- blink.cmp's Tab mapping (which is set during lsp.setup()).
	-- Priority: (1) accept copilot ghost text, (2) cycle blink menu, (3) indent.
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			vim.keymap.set("i", "<Tab>", function()
				local suggestion = require("copilot.suggestion")
				if suggestion.is_visible() then
					suggestion.accept()
					return
				end

				local blink_ok, blink = pcall(require, "blink.cmp")
				if blink_ok and blink.is_visible and blink.is_visible() then
					blink.select_next()
					return
				end

				vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes("<Tab>", true, false, true),
					"n",
					false
				)
			end, { silent = true, noremap = true, desc = "Accept Copilot suggestion, cycle completion, or indent" })
		end,
	})

	-- vim.api.nvim_create_autocmd("ColorScheme", {
	-- 	callback = function()
	-- 		vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#83a598", italic = true })
	-- 		vim.api.nvim_set_hl(0, "CopilotAnnotation", { fg = "#83a598" })
	-- 	end,
	-- })
end

return config
