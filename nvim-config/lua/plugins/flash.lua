return {
  "folke/flash.nvim",
  opts = {
    modes = {
      char = {
        char_actions = function()
          return {

            [";"] = "next",
            [","] = "prev",
          }
        end,
      },
    },
  },
}
