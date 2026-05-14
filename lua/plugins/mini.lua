return {
  {
    "nvim-mini/mini.hipatterns",
    event = "LazyFile",
    opts = function()
      local hipatterns = require("mini.hipatterns")

      return {
        highlighters = {
          hex_color = hipatterns.gen_highlighter.hex_color({ priority = 2000 }),
        },
      }
    end,
  },
}
