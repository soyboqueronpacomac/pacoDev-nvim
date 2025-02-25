local ollamaURL = nixCats("ollama")

return {
  "olimorris/codecompanion.nvim",
  enabled = require("nixCatsUtils").enableForCategory("ai") and ollamaURL ~= nil,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  event = { "VeryLazy" },
  opts = {
    strategies = {
      chat = {
        adapter = "copilot",
      },
      inline = {
        adapter = "copilot",
      },
    },
    adapters = {
      phi4 = function()
        return require("codecompanion.adapters").extend("ollama", {
          env = {
            url = ollamaURL,
          },
          schema = {
            model = {
              default = "phi4",
            },
          },
        })
      end,

      deepseek = function()
        return require("codecompanion.adapters").extend("ollama", {
          env = {
            url = ollamaURL,
          },
          schema = {
            model = {
              default = "deepseek-r1:14b",
            },
          },
        })
      end,
    },
  },
}
