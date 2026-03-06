vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true -- If you can't run neovim its probably because you don't have a nerd font so set this to false or install one

vim.opt.number = true
vim.opt.showmode = true

vim.o.autoindent = true
vim.o.smartindent = true
vim.o.smoothscroll = true

vim.opt.mouse = "a"

vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

require("custom.keymaps").setup()
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
require("lazy").setup({
	-- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

	{ import = "custom.plugins" },
})

function CreateSveltekitRoute()
	-- Prompt for the directory where the new route should go
	local route_directory = vim.fn.input("Route directory (relative to src/routes/): ", "", "file")
	if route_directory == "" then
		print("No directory provided.")
		return
	end

	-- Prompt for the route name
	local route_name = vim.fn.input("Route name: ")
	if route_name == "" then
		print("No route name provided.")
		return
	end

	-- Define the full path for the new route
	local base_path = "src/routes/" .. route_directory .. "/" .. route_name
	local svelte_file = base_path .. "/+page.svelte"
	local server_file = base_path .. "/+page.server.ts"

	-- Create the route directory if it doesn't exist
	vim.fn.mkdir(base_path, "p")

	-- Add boilerplate content for +page.svelte
	local svelte_content = [[
<script>
  // Add your component logic here
</script>

<h1>]] .. route_name .. [[</h1>
<p>This is the new SvelteKit route for ]] .. route_name .. [[.</p>
]]
	local server_content = [[
// +page.server.ts for route ]] .. route_name .. [[

export const load = async () => {
  return {
    // Your data here
  };
};
]]

	-- Write the +page.svelte file
	local svelte_file_handle = io.open(svelte_file, "w")
	if not svelte_file_handle then
		print("Error creating file: " .. svelte_file)
		return
	end
	svelte_file_handle:write(svelte_content)
	svelte_file_handle:close()

	-- Write the +page.server.ts file
	local server_file_handle = io.open(server_file, "w")
	if not server_file_handle then
		print("Error creating file: " .. server_file)
		return
	end
	server_file_handle:write(server_content)
	server_file_handle:close()

	print("SvelteKit route created at " .. base_path)
end

