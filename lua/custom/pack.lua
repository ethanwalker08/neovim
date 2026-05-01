local M = {}

local STATE_PATH = vim.fs.joinpath(vim.fn.stdpath("state"), "pack-specs.json")
local declared_specs = {}

local function infer_name(src)
	local trimmed = src:gsub("/+$", "")
	local name = trimmed:match("/([^/]+)$") or trimmed
	return name:gsub("%.git$", "")
end

local function serialize(value)
	local value_type = type(value)
	if value_type == "nil" or value_type == "string" or value_type == "number" or value_type == "boolean" then
		return value
	end

	if value_type == "table" then
		local ok, encoded = pcall(vim.json.encode, value)
		if ok then
			return encoded
		end
	end

	return tostring(value)
end

local function snapshot_specs(specs)
	local plugins = {}

	for _, spec in ipairs(specs) do
		if type(spec) == "string" then
			local name = infer_name(spec)
			plugins[name] = { src = spec }
		else
			local name = spec.name or infer_name(spec.src)
			plugins[name] = {
				src = spec.src,
				version = serialize(spec.version),
				branch = serialize(spec.branch),
				build = serialize(spec.build),
			}
		end
	end

	return { plugins = plugins }
end

local function read_state()
	if vim.fn.filereadable(STATE_PATH) == 0 then
		return { plugins = {} }
	end

	local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(STATE_PATH), "\n"))
	if not ok or type(decoded) ~= "table" or type(decoded.plugins) ~= "table" then
		return { plugins = {} }
	end

	return decoded
end

local function write_state(state)
	vim.fn.writefile({ vim.json.encode(state) }, STATE_PATH)
end

local function inactive_plugin_names()
	local names = vim
		.iter(vim.pack.get())
		:filter(function(plugin)
			return not plugin.active
		end)
		:map(function(plugin)
			return plugin.spec.name
		end)
		:totable()

	table.sort(names)
	return names
end

local function changed_declared_plugins(previous, current)
	local names = {}

	for name, spec in pairs(current.plugins) do
		local old_spec = previous.plugins[name]
		if old_spec ~= nil and not vim.deep_equal(spec, old_spec) then
			table.insert(names, name)
		end
	end

	table.sort(names)
	return names
end

local function sync_declared_plugins()
	local previous = read_state()
	local current = snapshot_specs(declared_specs)
	local changed_plugins = changed_declared_plugins(previous, current)

	M.clean()

	if #changed_plugins > 0 then
		local ok, err = pcall(vim.pack.update, changed_plugins, { force = true })
		if not ok then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end
	end

	write_state(current)
end

function M.clean()
	local names = inactive_plugin_names()
	if #names == 0 then
		return
	end

	vim.pack.del(names)
end

function M.setup(specs)
	declared_specs = specs

	vim.api.nvim_create_user_command("PackClean", function()
		M.clean()
	end, { desc = "Remove inactive vim.pack plugins from disk" })

	vim.api.nvim_create_user_command("PackSync", function()
		M.clean()
		local ok, err = pcall(vim.pack.update, nil, { force = true })
		if not ok then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end

		write_state(snapshot_specs(declared_specs))
	end, { desc = "Clean inactive plugins and update all vim.pack plugins" })

	vim.schedule(sync_declared_plugins)
end

return M
