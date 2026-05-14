return {
  { "nvim-mini/mini.clue", enabled = false },
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      local filtered = {}
      local remove = {
        ["<leader><tab>"] = true,
        ["<leader>b"] = true,
        ["<leader>c"] = true,
        ["<leader>d"] = true,
        ["<leader>f"] = true,
        ["<leader>g"] = true,
        ["<leader>q"] = true,
        ["<leader>s"] = true,
        ["<leader>u"] = true,
        ["<leader>w"] = true,
        ["<leader>x"] = true,
      }

      for _, entry in ipairs(opts.spec or {}) do
        if entry[1] == nil then
          local keep = { mode = entry.mode }
          local count = 0

          for _, child in ipairs(entry) do
            if not remove[child[1]] then
              count = count + 1
              keep[count] = child
            end
          end

          if count > 0 then
            filtered[#filtered + 1] = keep
          end
        else
          filtered[#filtered + 1] = entry
        end
      end

      opts.spec = filtered

      vim.list_extend(opts.spec, {
        {
          mode = { "n", "x" },
          { "<leader><tab>", hidden = true },
          { "<leader>b", hidden = true },
          { "<leader>c", group = "+[C]ode/[C]opilot" },
          { "<leader>f", desc = "[F]ormat" },
        },
        {
          mode = "n",
          { "<leader>d", group = "+[D]ebug" },
          { "<leader>e", desc = "[E]xplorer" },
          { "<leader>g", group = "+[G]oto/[G]it" },
          { "<leader>l", group = "+[L]azygit" },
          { "<leader>q", group = "+[Q]uit/[S]ession" },
          { "<leader>s", group = "+[S]earch" },
          { "<leader>t", group = "+[T]erminal" },
          { "<leader>u", group = "+[U]I" },
          { "<leader>w", desc = "[W]rite Buffer" },
          { "<leader>x", group = "+Diagnosti[x]/Quickfi[x]/[X]tras" },
          { "<leader>cs", group = "+[S]urround" },
        },
      })
    end,
  },
}
