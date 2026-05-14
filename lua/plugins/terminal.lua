local terminal_cwd = {}

local function terminal_opts(kind, cwd)
  return {
    count = 1,
    cwd = cwd,
    env = {
      NVIM_FLOATING_TERM_KIND = kind,
      NVIM_FLOATING_TERM_CWD = cwd,
    },
    win = {
      position = "float",
      width = 0.8,
      height = 0.8,
      border = "rounded",
      backdrop = false,
      stack = false,
      wo = {
        number = false,
        relativenumber = false,
        signcolumn = "no",
      },
      keys = {
        term_normal = false,
        esc_hide = { "<Esc>", "hide", mode = "t", desc = "Hide Terminal" },
      },
      on_buf = function(term)
        if term.meta.migration_bufleave then
          return
        end

        term.meta.migration_bufleave = true
        term:on("BufLeave", function(self)
          if self:valid() then
            self:hide()
          end
        end, { buf = true })
      end,
    },
  }
end

local function terminal_kind(term)
  if not term or not term:buf_valid() then
    return nil
  end

  local state = vim.b[term.buf].snacks_terminal
  return state and state.env and state.env.NVIM_FLOATING_TERM_KIND or nil
end

local function hide_other_terminals(kind)
  for _, term in ipairs(Snacks.terminal.list()) do
    if terminal_kind(term) ~= kind and term:valid() then
      term:hide()
    end
  end
end

local function toggle_terminal(kind, cmd)
  terminal_cwd[kind] = terminal_cwd[kind] or vim.fn.getcwd(0)

  local opts = terminal_opts(kind, terminal_cwd[kind])
  local term = Snacks.terminal.get(cmd, vim.tbl_extend("force", opts, { create = false }))
  if term and term:valid() then
    term:hide()
    return
  end

  hide_other_terminals(kind)
  Snacks.terminal(cmd, opts)
end

local function toggle_shell()
  toggle_terminal("shell", nil)
end

local function toggle_copilot()
  if vim.fn.executable("copilot") == 0 then
    vim.notify("copilot CLI is not installed", vim.log.levels.ERROR, { title = "Copilot CLI" })
    return
  end

  toggle_terminal("copilot", { "copilot" })
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          wo = {
            number = false,
            relativenumber = false,
            signcolumn = "no",
          },
          keys = {
            term_normal = false,
            esc_hide = { "<Esc>", "hide", mode = "t", desc = "Hide Terminal" },
          },
        },
      },
    },
    keys = {
      { "<leader>t", toggle_shell, desc = "Terminal" },
      { "<leader>cc", toggle_copilot, desc = "Copilot CLI" },
    },
  },
}
