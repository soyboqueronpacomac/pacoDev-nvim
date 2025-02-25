local formatters = {
  lua = { "stylua", lsp_format = "fallback" },
  nix = { "nixfmt" },
  json = { "jq" },
}

if require("nixCatsUtils").enableForCategory("go") then
  formatters.go = { "gofmt", "goimports" }
end

if require("nixCatsUtils").enableForCategory("laravel") then
  formatters.blade = { "blade-formatter" }
  formatters.php = { "pint" }
end

return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = formatters,
  },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format()
      end,
    },
  },
}
