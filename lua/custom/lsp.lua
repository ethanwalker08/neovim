local M = {}

local function disable_client_formatting(client)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
end

function M.setup()
	local lsp_augroup = vim.api.nvim_create_augroup("custom-lsp", { clear = true })
	local capabilities = require("blink.cmp").get_lsp_capabilities()
	local format_managed_servers = {
		cssls = true,
		eslint = true,
		html = true,
		jsonls = true,
		lua_ls = true,
		pyright = true,
		ruff = true,
		svelte = true,
		tailwindcss = true,
		ts_ls = true,
	}
	local servers = {
		lua_ls = {
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace",
					},
					diagnostics = {
						globals = { "vim", "Snacks" },
					},
					telemetry = { enable = false },
					workspace = {
						checkThirdParty = false,
					},
				},
			},
		},
		ts_ls = {
			init_options = {
				hostInfo = "neovim",
			},
		},
		eslint = {
			settings = {
				workingDirectory = {
					mode = "auto",
				},
			},
		},
		svelte = {},
		tailwindcss = {},
		html = {},
		cssls = {},
		jsonls = {},
		pyright = {
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						diagnosticMode = "openFilesOnly",
						typeCheckingMode = "basic",
						useLibraryCodeForTypes = true,
						disableOrganizeImports = true,
					},
					venv = ".venv",
					venvPath = ".",
				},
			},
		},
		ruff = {
			init_options = {
				settings = {},
			},
		},
	}
	local lsp_ensure_installed = vim.tbl_keys(servers)

	require("mason").setup({
		ui = {
			border = "rounded",
		},
	})
	require("mason-tool-installer").setup({
		ensure_installed = {
			"mypy",
			"stylua",
		},
		run_on_start = true,
		start_delay = 3000,
		debounce_hours = 12,
	})
	require("mason-lspconfig").setup({
		ensure_installed = lsp_ensure_installed,
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

		if format_managed_servers[client.name] then
			disable_client_formatting(client)
		end

		local bufnr = ev.buf
		local telescope = require("telescope.builtin")
		local opts = function(desc)
			return { noremap = true, silent = true, buffer = bufnr, desc = desc }
		end

		vim.keymap.set("n", "<leader>gd", telescope.lsp_definitions, opts("LSP: [G]oto [D]efinition"))
		vim.keymap.set("n", "<leader>gr", telescope.lsp_references, opts("LSP: Find [R]eferences"))
		vim.keymap.set("n", "<leader>cr", telescope.lsp_references, opts("LSP: Find [R]eferences"))
		vim.keymap.set("n", "<leader>gi", telescope.lsp_implementations, opts("LSP: [G]oto [I]mplementation"))
		vim.keymap.set("n", "<leader>gt", telescope.lsp_type_definitions, opts("LSP: [G]oto [T]ype Definition"))
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("LSP: [C]ode [A]ction"))
		vim.keymap.set("n", "<leader>cd", vim.lsp.buf.hover, opts("LSP: [C]ode [D]ocs"))

		if client.name == "svelte" then
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = vim.api.nvim_create_augroup("custom-svelte-js-ts-sync", { clear = true }),
				pattern = { "*.js", "*.ts" },
				callback = function(ctx)
					---@diagnostic disable-next-line: param-type-mismatch
					client:notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
				end,
			})
		end
	end

	vim.api.nvim_create_autocmd("LspAttach", { group = lsp_augroup, callback = lsp_on_attach })

	vim.api.nvim_create_autocmd("FileType", {
		group = lsp_augroup,
		pattern = { "markdown", "text", "gitcommit" },
		callback = function()
			vim.opt_local.wrap = true
			vim.opt_local.linebreak = true
			vim.opt_local.spell = true
		end,
	})

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

	for server_name, server_opts in pairs(servers) do
		vim.lsp.config(server_name, vim.tbl_deep_extend("force", {
			capabilities = capabilities,
		}, server_opts))
	end
end

return M
