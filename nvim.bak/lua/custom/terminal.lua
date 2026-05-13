local M = {}

local terminal_states = {
	shell = { buf = nil, win = nil, is_open = false, job_id = nil },
	copilot = { buf = nil, win = nil, is_open = false, job_id = nil },
}

local function set_float_highlights()
	vim.api.nvim_set_hl(0, "FloatingTermNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatingTermBorder", { bg = "none" })
end

local function close_terminal(state)
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, false)
	end

	state.win = nil
	state.is_open = false
end

local function close_other_terminals(active_name)
	for name, state in pairs(terminal_states) do
		if name ~= active_name and state.is_open then
			close_terminal(state)
		end
	end
end

local function get_terminal_shell()
	if vim.o.shell ~= "" then
		return vim.o.shell
	end

	return os.getenv("SHELL") or "sh"
end

local function ensure_terminal_buffer(state)
	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		return
	end

	state.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.buf].bufhidden = "hide"
	state.job_id = nil
end

local function is_job_running(job_id)
	if not job_id or job_id <= 0 then
		return false
	end

	return vim.fn.jobwait({ job_id }, 0)[1] == -1
end

local function open_terminal_job(state, command, kind)
	local cwd = vim.fn.getcwd()

	state.job_id = vim.fn.termopen(command, {
		cwd = cwd,
		env = {
			NVIM_FLOATING_TERM_CWD = cwd,
			NVIM_FLOATING_TERM_KIND = kind,
		},
	})
end

local function open_floating_terminal(name, command)
	local state = terminal_states[name]

	if state.is_open and state.win and vim.api.nvim_win_is_valid(state.win) then
		close_terminal(state)
		return
	end

	close_other_terminals(name)
	ensure_terminal_buffer(state)

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	state.win = vim.api.nvim_open_win(state.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	vim.wo[state.win].winblend = 0
	vim.wo[state.win].winhighlight = "Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder"

	if not is_job_running(state.job_id) then
		open_terminal_job(state, command, name)
	end

	state.is_open = true
	vim.cmd("startinsert")

	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = state.buf,
		callback = function()
			if state.is_open and state.win and vim.api.nvim_win_is_valid(state.win) then
				close_terminal(state)
			end
		end,
		once = true,
	})
end

function M.toggle()
	open_floating_terminal("shell", get_terminal_shell())
end

function M.open_copilot()
	open_floating_terminal("copilot", { "copilot" })
end

function M.close()
	for _, state in pairs(terminal_states) do
		if state.is_open then
			close_terminal(state)
		end
	end
end

function M.setup()
	set_float_highlights()

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = augroup,
		callback = set_float_highlights,
	})

	vim.api.nvim_create_autocmd("TermClose", {
		group = augroup,
		callback = function(args)
			for _, state in pairs(terminal_states) do
				if state.buf == args.buf then
					state.job_id = nil
					state.win = nil
					state.is_open = false

					if vim.v.event.status == 0 and vim.api.nvim_buf_is_valid(args.buf) then
						vim.api.nvim_buf_delete(args.buf, {})
						state.buf = nil
					end

					break
				end
			end
		end,
	})

	vim.api.nvim_create_autocmd("TermOpen", {
		group = augroup,
		callback = function()
			vim.opt_local.number = false
			vim.opt_local.relativenumber = false
			vim.opt_local.signcolumn = "no"
		end,
	})
end

return M
