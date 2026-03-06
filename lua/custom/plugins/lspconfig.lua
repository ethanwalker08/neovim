return {
	-- Main LSP Configuration
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Automatically install LSPs and related tools to stdpath for Neovim
		{ "williamboman/mason.nvim", config = true },
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",

		-- Useful status updates for LSP.
		{ "j-hui/fidget.nvim", opts = {} },

		-- Allows extra capabilities provided by nvim-cmp
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		local util = require("lspconfig.util")
		local deno_root = util.root_pattern("deno.json", "deno.jsonc")
		local node_root = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")
		local default_server_opts = {
			flags = {
				-- Reduce update chatter while typing for lower CPU usage.
				debounce_text_changes = 150,
			},
		}
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				require("custom.keymaps").on_lsp_attach(event)

				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
						end,
					})
				end
			end,
		})
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
		local servers = {
			-- clangd = {},
			-- Deno language server
			denols = {
				root_dir = deno_root,
				single_file_support = false,
			},
			-- TypeScript/JavaScript server for non-Deno projects
			ts_ls = {
				root_dir = function(fname)
					if deno_root(fname) then
						return nil
					end
					return node_root(fname)
				end,
				single_file_support = false,
			},
			-- gopls = {},
			-- pyright = {},
			-- rust_analyzer = {},
			-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
			--
			-- Some languages (like typescript) have entire language plugins that can be useful:
			--    https://github.com/pmizio/typescript-tools.nvim
			-- But for many setups, the LSP (`ts_ls`) will work just fine

			lua_ls = {
				-- cmd = {...},
				-- filetypes = { ...},
				-- capabilities = {},
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						workspace = {
							checkThirdParty = false,
							maxPreload = 2000,
							preloadFileSize = 150,
						},
						-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
						diagnostics = { disable = { "missing-fields" } },
						telemetry = { enable = false },
					},
				},
			},
		}
		require("mason").setup({
			registries = {
				"github:mason-org/mason-registry",
				-- "github:crashdummyy/mason-registry", -- For .net stuff uncomment if you need it for like a blazor or razor project or something
			},
		})
		-- LSP servers managed by mason-lspconfig.
		local lsp_ensure_installed = vim.tbl_keys(servers or {})

		-- Non-LSP tools managed by mason-tool-installer.
		local tool_ensure_installed = {
			"stylua",
			"prettierd",
			"dcm",
		}
		require("mason-tool-installer").setup({
			ensure_installed = vim.list_extend(vim.deepcopy(lsp_ensure_installed), tool_ensure_installed),
			run_on_start = true,
			start_delay = 3000,
			debounce_hours = 12,
		})

		-- Ensure mason-lspconfig auto-installs servers we list in `servers`.
		require("mason-lspconfig").setup({
			ensure_installed = lsp_ensure_installed,
			automatic_installation = true,
			handlers = {
				function(server_name)
					local server = vim.tbl_deep_extend("force", {}, default_server_opts, servers[server_name] or {})
					-- This handles overriding only values explicitly passed
					-- by the server configuration above. Useful when disabling
					-- certain features of an LSP (for example, turning off formatting for ts_ls)
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					-- Use direct configs module to avoid deprecated `require('lspconfig')[name]` access
					local configs = require("lspconfig.configs")
					configs[server_name].setup(server)
				end,
			},
		})
	end,
}
