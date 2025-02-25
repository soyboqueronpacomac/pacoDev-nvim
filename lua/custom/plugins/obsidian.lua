local vaults = {
  {
    name = "personal",
    path = "~/vaults/personal",
  },
  {
    name = "work",
    path = "~/vaults/work",
  },
}

local events = vim
  .iter(vaults)
  :map(function(vault)
    return vim.fn.expand(vault.path)
  end)
  :map(function(vault)
    return {
      string.format("BufReadPre %s/*.md", vault),
      string.format("BufNewFile %s/*.md", vault),
    }
  end)
  :flatten()
  :totable()

return {
  "epwalsh/obsidian.nvim",
  enabled = require("nixCatsUtils").enableForCategory("obsidian"),
  version = "*",
  lazy = true,
  event = events,
  cmd = {
    "ObsidianMenu",
  },
  keys = {
    { "<leader>ob", "<cmd> ObsidianMenu<cr>" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
  },
  opts = {
    workspaces = vaults,
  },
  config = function(_, opts)
    require("obsidian").setup(opts)

    local actions = {
      Search = "ObsidianSearch",
      Today = "ObsidianToday",
      Yesterday = "ObsidianYesterday",
      Tomorrow = "ObsidianTomorrow",
    }

    vim.api.nvim_create_user_command("ObsidianMenu", function()
      vim.ui.select(vim.tbl_keys(actions), { prompt = "Obsidian Action" }, function(selected)
        vim.cmd(actions[selected])
      end)
    end, {})
  end,
}
