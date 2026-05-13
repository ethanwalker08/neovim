local M = {}

local JS_FILETYPES = {
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
	"svelte",
}
local JS_DEBUG_HOST = "127.0.0.1"
local JS_DEBUG_TYPE_ALIASES = {
	chrome = "pwa-chrome",
	msedge = "pwa-msedge",
	node = "pwa-node",
}
local PROJECT_FILETYPE_GROUPS = {
	{
		filetypes = JS_FILETYPES,
		markers = {
			"package.json",
			"tsconfig.json",
			"jsconfig.json",
			"svelte.config.js",
			"svelte.config.ts",
			"vite.config.js",
			"vite.config.ts",
			"vite.config.mjs",
			"vite.config.cjs",
		},
	},
	{
		filetypes = { "python" },
		markers = {
			"pyproject.toml",
			"requirements.txt",
			"setup.py",
			"setup.cfg",
			"Pipfile",
			"manage.py",
		},
	},
	{
		filetypes = { "go" },
		markers = { "go.mod" },
	},
	{
		filetypes = { "rust" },
		markers = { "Cargo.toml" },
	},
	{
		filetypes = { "zig" },
		markers = { "build.zig" },
	},
	{
		filetypes = { "swift" },
		markers = { "Package.swift" },
	},
	{
		filetypes = { "c", "cpp" },
		markers = {
			"CMakeLists.txt",
			"compile_commands.json",
			"meson.build",
			"Makefile",
		},
	},
}
local IGNORED_PROJECT_DIRS = {
	[".cache"] = true,
	[".git"] = true,
	[".next"] = true,
	[".nuxt"] = true,
	[".svelte-kit"] = true,
	[".venv"] = true,
	["__pycache__"] = true,
	build = true,
	coverage = true,
	dist = true,
	node_modules = true,
	target = true,
	venv = true,
}

local VSCODE_FILETYPE_MAP = {
	node = JS_FILETYPES,
	["node-terminal"] = JS_FILETYPES,
	["pwa-node"] = JS_FILETYPES,
	chrome = JS_FILETYPES,
	["pwa-chrome"] = JS_FILETYPES,
	msedge = JS_FILETYPES,
	["pwa-msedge"] = JS_FILETYPES,
	python = { "python" },
	codelldb = { "c", "cpp", "rust", "swift", "zig" },
	delve = { "go" },
	bash = { "sh" },
}

local function split_args(input)
	if input == "" then
		return {}
	end

	return vim.split(input, " +", { trimempty = true })
end

local function prompt_args()
	return split_args(vim.fn.input("Args: "))
end

local function executable(path)
	return path ~= nil and path ~= "" and vim.fn.executable(path) == 1
end

local function resolve_python_path()
	local cwd = vim.fn.getcwd()
	local candidates = {
		vim.env.VIRTUAL_ENV and vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python"),
		vim.env.CONDA_PREFIX and vim.fs.joinpath(vim.env.CONDA_PREFIX, "bin", "python"),
		vim.fs.joinpath(cwd, ".venv", "bin", "python"),
		vim.fs.joinpath(cwd, "venv", "bin", "python"),
		vim.fn.exepath("python3"),
		vim.fn.exepath("python"),
	}

	for _, candidate in ipairs(candidates) do
		if executable(candidate) then
			return candidate
		end
	end

	return "python3"
end

local function add_filetypes(target, filetypes)
	for _, filetype in ipairs(filetypes) do
		target[filetype] = true
	end
end

local function project_root()
	return vim.fs.normalize(vim.fn.getcwd())
end

local function find_launch_files()
	local root = project_root()
	local launch_files = {}

	if vim.fn.executable("rg") == 1 then
		local result = vim.system({
			"rg",
			"-l",
			"--hidden",
			"-g",
			"**/.vscode/launch.json",
			"-g",
			"!**/node_modules/**",
			"-g",
			"!**/.git/**",
			"-g",
			"!**/.venv/**",
			"-g",
			"!**/venv/**",
			'"configurations"',
			".",
		}, {
			cwd = root,
			text = true,
		}):wait()

		if result.code == 0 or result.code == 1 then
			for _, path in ipairs(vim.split(result.stdout or "", "\n", { trimempty = true })) do
				table.insert(launch_files, vim.fs.normalize(vim.fs.joinpath(root, path)))
			end

			table.sort(launch_files)
			return launch_files
		end
	end

	local function scan(dir)
		local vscode_dir = vim.fs.joinpath(dir, ".vscode")
		local launch_path = vim.fs.joinpath(vscode_dir, "launch.json")
		if vim.uv.fs_stat(launch_path) then
			table.insert(launch_files, vim.fs.normalize(launch_path))
		end

		for name, type in vim.fs.dir(dir) do
			if type == "directory" and name ~= ".vscode" and not IGNORED_PROJECT_DIRS[name] then
				scan(vim.fs.joinpath(dir, name))
			end
		end
	end

	scan(root)
	table.sort(launch_files)
	return launch_files
end

local function launch_workspace(launch_file)
	return vim.fs.dirname(vim.fs.dirname(launch_file))
end

local function replace_workspace_tokens(value, workspace_dir)
	if type(value) == "string" then
		return value
			:gsub("%${workspaceFolder}", workspace_dir)
			:gsub("%${workspaceFolderBasename}", vim.fs.basename(workspace_dir))
	end

	if type(value) ~= "table" then
		return value
	end

	local result = {}
	for key, item in pairs(value) do
		result[replace_workspace_tokens(key, workspace_dir)] = replace_workspace_tokens(item, workspace_dir)
	end

	return setmetatable(result, getmetatable(value))
end

local function normalize_launch_config(config, launch_file)
	local workspace_dir = launch_workspace(launch_file)
	local resolved_config = config

	if getmetatable(config) and getmetatable(config).__call then
		resolved_config = config()
	end

	local normalized = replace_workspace_tokens(vim.deepcopy(resolved_config), workspace_dir)
	normalized.type = JS_DEBUG_TYPE_ALIASES[normalized.type] or normalized.type
	normalized.cwd = normalized.cwd or workspace_dir
	normalized.__workspace_dir = workspace_dir
	normalized.__launch_file = launch_file
	normalized.__source = "launch.json"

	return normalized
end

local function collect_launch_configurations()
	local vscode = require("dap.ext.vscode")
	local configurations = {}

	for _, launch_file in ipairs(find_launch_files()) do
		for _, config in ipairs(vscode.getconfigs(launch_file)) do
			table.insert(configurations, normalize_launch_config(config, launch_file))
		end
	end

	return configurations
end

local function collect_project_filetypes()
	local filetypes = {}

	for _, config in ipairs(collect_launch_configurations()) do
		local config_filetypes = config.type and VSCODE_FILETYPE_MAP[config.type]
		if config_filetypes then
			add_filetypes(filetypes, config_filetypes)
		end
	end

	for _, group in ipairs(PROJECT_FILETYPE_GROUPS) do
		if vim.fs.find(group.markers, { upward = true, path = vim.fn.getcwd(), limit = 1 })[1] then
			add_filetypes(filetypes, group.filetypes)
		end
	end

	if next(filetypes) == nil and vim.bo.filetype ~= "" then
		filetypes[vim.bo.filetype] = true
	end

	return filetypes
end

local function configuration_key(config)
	local program = type(config.program) == "string" and config.program or ""
	local module_name = type(config.module) == "string" and config.module or ""
	local cwd = type(config.cwd) == "string" and config.cwd or ""
	local runtime = type(config.runtimeExecutable) == "string" and config.runtimeExecutable or ""
	local launch_file = type(config.__launch_file) == "string" and config.__launch_file or ""

	return table.concat({
		config.name or "",
		config.type or "",
		config.request or "",
		program,
		module_name,
		cwd,
		runtime,
		launch_file,
	}, "\0")
end

local function workspace_label(config, filetype)
	local workspace_dir = config.__workspace_dir
	if not workspace_dir then
		return filetype
	end

	local root = project_root()
	if workspace_dir == root then
		return vim.fs.basename(root)
	end

	local relative = vim.fn.fnamemodify(workspace_dir, ":.")
	if relative == "." then
		return vim.fs.basename(workspace_dir)
	end

	return relative
end

local function js_adapter(mode)
	return {
		type = "server",
		host = JS_DEBUG_HOST,
		port = "${port}",
		id = mode,
		executable = {
			command = "js-debug-adapter",
			args = { "${port}", JS_DEBUG_HOST },
		},
	}
end

local function collect_project_configurations()
	local configurations = {}
	local seen = {}
	local dap = require("dap")

	for _, config in ipairs(collect_launch_configurations()) do
		local key = configuration_key(config)
		if not seen[key] then
			seen[key] = true
			table.insert(configurations, {
				filetype = config.type or "launch",
				config = config,
			})
		end
	end

	for filetype in pairs(collect_project_filetypes()) do
		for _, config in ipairs(dap.configurations[filetype] or {}) do
			local key = configuration_key(config)
			if not seen[key] then
				seen[key] = true
				table.insert(configurations, {
					filetype = filetype,
					config = config,
				})
			end
		end
	end

	table.sort(configurations, function(left, right)
		local left_source = left.config.__source == "launch.json" and 0 or 1
		local right_source = right.config.__source == "launch.json" and 0 or 1
		if left_source ~= right_source then
			return left_source < right_source
		end

		if left.config.name == right.config.name then
			return workspace_label(left.config, left.filetype) < workspace_label(right.config, right.filetype)
		end

		return left.config.name < right.config.name
	end)

	return configurations
end

local function select_configuration(configurations, prompt, empty_message, callback)
	if #configurations == 0 then
		vim.notify(empty_message, vim.log.levels.WARN)
		return
	end

	if #configurations == 1 then
		callback(configurations[1].config)
		return
	end

	vim.ui.select(configurations, {
		prompt = prompt,
		format_item = function(item)
			local scope = workspace_label(item.config, item.filetype)
			return string.format("%s [%s]", item.config.name, scope)
		end,
	}, function(choice)
		if choice then
			callback(choice.config)
		end
	end)
end

local function select_project_configuration(callback)
	select_configuration(
		collect_project_configurations(),
		"Project debug configuration",
		"No debug configurations found for the current project",
		callback
	)
end

local function select_launch_configuration(callback)
	local configurations = {}

	for _, config in ipairs(collect_launch_configurations()) do
		table.insert(configurations, {
			filetype = config.type or "launch",
			config = config,
		})
	end

	table.sort(configurations, function(left, right)
		if left.config.name == right.config.name then
			return workspace_label(left.config, left.filetype) < workspace_label(right.config, right.filetype)
		end

		return left.config.name < right.config.name
	end)

	select_configuration(
		configurations,
		"Launch debug configuration",
		"No launch.json debug configurations found for the current project",
		callback
	)
end

local function setup_signs()
	local signs = {
		DapBreakpoint = { text = "●", texthl = "DiagnosticSignError" },
		DapBreakpointCondition = { text = "◆", texthl = "DiagnosticSignWarn" },
		DapBreakpointRejected = { text = "", texthl = "DiagnosticSignError" },
		DapLogPoint = { text = "󰰍", texthl = "DiagnosticSignInfo" },
		DapStopped = {
			text = "▶",
			texthl = "DiagnosticSignHint",
			linehl = "Visual",
			numhl = "DiagnosticSignHint",
		},
	}

	for name, sign in pairs(signs) do
		vim.fn.sign_define(name, sign)
	end
end

local function setup_ui(dap, dapui)
	dapui.setup({
		controls = {
			enabled = true,
			element = "repl",
		},
		floating = {
			border = "rounded",
			mappings = {
				close = { "q", "<Esc>" },
			},
		},
		layouts = {
			{
				position = "left",
				size = 48,
				elements = {
					{ id = "scopes", size = 0.45 },
					{ id = "breakpoints", size = 0.15 },
					{ id = "stacks", size = 0.2 },
					{ id = "watches", size = 0.2 },
				},
			},
			{
				position = "bottom",
				size = 12,
				elements = {
					{ id = "console", size = 0.5 },
					{ id = "repl", size = 0.5 },
				},
			},
		},
		render = {
			max_type_length = 48,
			max_value_lines = 4,
		},
	})

	dap.listeners.after.event_initialized["custom-debugger-ui"] = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated["custom-debugger-ui"] = function()
		dapui.close()
	end
	dap.listeners.before.event_exited["custom-debugger-ui"] = function()
		dapui.close()
	end
	dap.listeners.before.disconnect["custom-debugger-ui"] = function()
		dapui.close()
	end
end

local function setup_mason_dap()
	require("mason-nvim-dap").setup({
		ensure_installed = {
			"bash",
			"codelldb",
			"delve",
			"js",
			"python",
		},
		handlers = {
			function(config)
				if config.name == "js" then
					return
				end

				require("mason-nvim-dap").default_setup(config)
			end,
		},
	})
end

local function setup_js_debugging(dap)
	dap.adapters["pwa-node"] = js_adapter("pwa-node")
	dap.adapters["node-terminal"] = js_adapter("node-terminal")
	dap.adapters["pwa-chrome"] = js_adapter("pwa-chrome")
	dap.adapters["pwa-msedge"] = js_adapter("pwa-msedge")
	dap.adapters["pwa-extensionHost"] = js_adapter("pwa-extensionHost")
	dap.adapters.node = dap.adapters["pwa-node"]
	dap.adapters.chrome = dap.adapters["pwa-chrome"]
	dap.adapters.msedge = dap.adapters["pwa-msedge"]

	local js_configurations = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch current file",
			program = "${file}",
			cwd = "${workspaceFolder}",
			console = "integratedTerminal",
			skipFiles = {
				"<node_internals>/**",
				"${workspaceFolder}/node_modules/**",
			},
		},
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch current file (with args)",
			program = "${file}",
			cwd = "${workspaceFolder}",
			args = prompt_args,
			console = "integratedTerminal",
			skipFiles = {
				"<node_internals>/**",
				"${workspaceFolder}/node_modules/**",
			},
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach to process",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
			skipFiles = {
				"<node_internals>/**",
				"${workspaceFolder}/node_modules/**",
			},
		},
		{
			type = "pwa-node",
			request = "launch",
			name = "Debug Jest current file",
			runtimeExecutable = "node",
			runtimeArgs = {
				"./node_modules/jest/bin/jest.js",
				"${file}",
				"--runInBand",
			},
			rootPath = "${workspaceFolder}",
			cwd = "${workspaceFolder}",
			console = "integratedTerminal",
			internalConsoleOptions = "neverOpen",
			skipFiles = {
				"<node_internals>/**",
				"${workspaceFolder}/node_modules/**",
			},
		},
	}

	for _, language in ipairs(JS_FILETYPES) do
		dap.configurations[language] = vim.deepcopy(js_configurations)
	end
end

local function setup_python_debugging(dap)
	dap.configurations.python = {
		{
			type = "python",
			request = "launch",
			name = "Launch current file",
			program = "${file}",
			pythonPath = resolve_python_path,
			console = "integratedTerminal",
		},
		{
			type = "python",
			request = "launch",
			name = "Launch current file (with args)",
			program = "${file}",
			pythonPath = resolve_python_path,
			args = prompt_args,
			console = "integratedTerminal",
		},
		{
			type = "python",
			request = "attach",
			name = "Attach to debugpy (:5678)",
			connect = {
				host = "127.0.0.1",
				port = 5678,
			},
		},
	}
end

local function open_telescope_picker(name)
	local ok, telescope = pcall(require, "telescope")
	if not ok then
		return false
	end

	local extensions = telescope.extensions
	if not extensions or not extensions.dap or not extensions.dap[name] then
		return false
	end

	extensions.dap[name]({})
	return true
end

local function float_element(name)
	require("dapui").float_element(name, {
		enter = true,
	})
end

function M.start_session()
	select_launch_configuration(function(config)
		require("dap").run(config)
	end)
end

function M.continue_session()
	local dap = require("dap")
	if dap.session() then
		dap.continue()
		return
	end

	select_project_configuration(function(config)
		dap.run(config)
	end)
end

function M.restart_last()
	require("dap").run_last()
end

function M.terminate()
	require("dap").terminate()
end

function M.pause()
	require("dap").pause()
end

function M.step_over()
	require("dap").step_over()
end

function M.step_into()
	require("dap").step_into()
end

function M.step_out()
	require("dap").step_out()
end

function M.toggle_ui()
	require("dapui").toggle()
end

function M.toggle_breakpoint()
	require("dap").toggle_breakpoint()
end

function M.set_conditional_breakpoint()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end

function M.set_log_point()
	require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end

function M.clear_breakpoints()
	require("dap").clear_breakpoints()
end

function M.pick_configuration()
	select_project_configuration(function(config)
		require("dap").run(config)
	end)
end

function M.pick_all_configurations()
	M.pick_configuration()
end

function M.toggle_repl()
	require("dap").repl.toggle()
end

function M.show_frames()
	if open_telescope_picker("frames") then
		return
	end

	float_element("stacks")
end

function M.show_scopes()
	if open_telescope_picker("variables") then
		return
	end

	float_element("scopes")
end

function M.show_watches()
	float_element("watches")
end

function M.eval()
	require("dapui").eval()
end

function M.setup()
	local dap = require("dap")
	local dapui = require("dapui")

	setup_signs()
	setup_ui(dap, dapui)
	setup_mason_dap()
	setup_js_debugging(dap)
	setup_python_debugging(dap)
	require("nvim-dap-virtual-text").setup({
		commented = true,
		show_stop_reason = true,
		virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
	})
end

return M
