require("nixCatsUtils").setup({
  non_nix_value = true,
})

require("core.options")
require("core.replace_action")
require("core.diagnostic")
require("core.autocommands")
require("custom.quickfixmaps")
require("custom.utilitymaps")

-- NOTE: nixCats: You might want to move the lazy-lock.json file
local function getlockfilepath()
  if require("nixCatsUtils").isNixCats and type(require("nixCats").settings.unwrappedCfgPath) == "string" then
    return require("nixCats").settings.unwrappedCfgPath .. "/lazy-lock.json"
  else
    return vim.fn.stdpath("config") .. "/lazy-lock.json"
  end
end

local lazyOptions = {
  lockfile = getlockfilepath(),
}

require("nixCatsUtils.lazyCat").setup(nixCats.pawsible({ "allPlugins", "start", "lazy.nvim" }), {
  require("core.lsp"),
  require("core.treesitter"),
  require("core.file_manager"),
  require("core.completion"),

  { import = "custom.plugins" },
}, lazyOptions)

require("tools")

-- TODO: search a better place for this
if require("nixCatsUtils").enableForCategory("symfony") then
  vim.opt.path:append("tests/**/httpstubs/**/")

  vim.keymap.set({ "n" }, "<leader>po", function()
    -- TODO: replace to read all from directory
    local schemas = vim
      .iter({
        "_mutation.yaml",
        "_mutation_external_anonymous.yaml",
        "_mutation_public_api.yaml",
        "_query.yaml",
        "_query_external_anonymous.yaml",
        "_query_public_api.yaml",
      })
      :map(function(schema)
        return vim.fn.findfile(schema, "config/graphql")
      end)
      :filter(function(path)
        return path ~= ""
      end)
      :map(function(path)
        return vim.fn.getcwd() .. "/" .. path
      end)
      :totable()

    require("custom.graphql").pick({
      schemas_path = schemas,
    })
  end, { desc = "Graphql Picker" })
end
