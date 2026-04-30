local lsp = {}

function lsp.setup()
	--- LSP ---
	require("mason").setup()
	require("mason-lspconfig").setup({
		automatic_enable = true,
	})
	vim.diagnostic.config({
		underline = true,
		update_in_insert = false,
		severity_sort = true,
		float = {
			border = "rounded",
			---@diagnostic disable-next-line: assign-type-mismatch
			source = "always",
			header = "",
			prefix = "",
			focusable = false,
			style = "minimal",
		},
	})
	do
		local orig = vim.lsp.util.open_floating_preview
		---@diagnostic disable-next-line: duplicate-set-field
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = opts.border or "rounded"
			return orig(contents, syntax, opts, ...)
		end
	end

	local function lsp_on_attach(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end

		local bufnr = ev.buf
		local opts = function(desc)
			return { noremap = true, silent = true, buffer = bufnr, desc = desc }
		end

		vim.keymap.set(
			"n",
			"<leader>gd",
			require("telescope.builtin").lsp_definitions,
			opts("LSP: [G]oto [D]efinition")
		)

		vim.keymap.set("n", "<leader>gr", require("telescope.builtin").lsp_references, opts("LSP: Find [R]eferences"))

		vim.keymap.set("n", "<leader>cr", require("telescope.builtin").lsp_references, opts("LSP: Find [R]eferences"))

		vim.keymap.set(
			"n",
			"<leader>gi",
			require("telescope.builtin").lsp_implementations,
			opts("LSP: [G]oto [I]mplementation")
		)

		vim.keymap.set(
			"n",
			"<leader>gt",
			require("telescope.builtin").lsp_type_definitions,
			opts("LSP: [G]oto [T]ype Definition")
		)

		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("LSP: [C]ode [A]ction"))

		vim.keymap.set("n", "<leader>cd", vim.lsp.buf.hover, opts("LSP: [C]ode [D]ocs"))
	end

	--- LSP Autocommands ---

	vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = { "markdown", "text", "gitcommit" },
		callback = function()
			vim.opt_local.wrap = true
			vim.opt_local.linebreak = true
			vim.opt_local.spell = true
		end,
	})

	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
				telemetry = { enable = false },
			},
		},
	})

	vim.lsp.config("pyright", {})
	vim.lsp.config("bashls", {})
	vim.lsp.config("gopls", {})
	vim.lsp.config("clangd", {})

	local function accept_copilot_suggestion()
		local ok, suggestion = pcall(require, "copilot.suggestion")
		if not ok or not suggestion.is_visible() then
			return
		end

		suggestion.accept()
		return true
	end

	require("blink.cmp").setup({
		keymap = {
			preset = "none",
			["<C-Space>"] = { "show", "hide" },
			["<CR>"] = { "accept", "fallback" },
			["<Tab>"] = { accept_copilot_suggestion, "select_next", "snippet_forward", "fallback" },
			["<C-Tab>"] = { "select_prev", "fallback" },
			["<Right>"] = { "snippet_forward", "fallback" },
			["<Left>"] = { "snippet_backward", "fallback" },
			["<Esc>"] = { "cancel", "fallback" },
		},
		appearance = { nerd_font_variant = "normal" },
		completion = {
			trigger = {
				prefetch_on_insert = true,
				show_in_snippet = true,
			},
			menu = {
				border = "rounded",
				auto_show = false,
				min_width = 50,
			},
			documentation = {
				auto_show = true,
				treesitter_highlighting = true,
				window = {
					border = "rounded",
				},
			},
			ghost_text = {
				enabled = false,
			},
		},
		sources = {
			default = {
				"lsp",
				"path",
				"buffer",
				"snippets",
				"omni",
			},
		},
		snippets = {
			expand = function(snippet)
				require("luasnip").lsp_expand(snippet)
			end,
		},
		signature = {
			enabled = true,
			window = {
				border = "rounded",
			},
		},

		fuzzy = {
			implementation = "prefer_rust",
			prebuilt_binaries = { download = true },
		},
	})

	vim.lsp.config["*"] = {
		capabilities = require("blink.cmp").get_lsp_capabilities(),
	}
end

return lsp
