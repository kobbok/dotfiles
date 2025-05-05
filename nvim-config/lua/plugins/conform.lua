return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  opts = function()
    ---@type conform.setupOpts
    local opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false,           -- not recommended to change
        quiet = false,           -- not recommended to change
        lsp_format = "fallback", -- not recommended to change
      },
      formatters_by_ft = {
        markdown = { "prettier" },
      },
      -- The options you set here will be merged with the builtin formatters.
      -- You can also define any custom formatters here.
      ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
      formatters = {
        injected = { options = { ignore_errors = true } },
        -- # Example of using dprint only when a dprint.json file is present
        -- dprint = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        --
        -- # Example of using shfmt with extra args
        -- shfmt = {
        --   prepend_args = { "-i", "2", "-ci" },
        -- },
        lemminx = {
          settings = {
            xml = {
              format = {
                enabled = true,
                splitAttributes = true,
                joinContentLines = true,
              }
            }
          },
        },
        xmlformat = {
          command = "xmlformat",
          args = { "--blanks", "--selfclose", "--preserve-attributes", "-" },
          stdin = true,
        },
      },
    }
    return opts
  end,
}
