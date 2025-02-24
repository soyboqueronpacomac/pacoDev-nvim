require('nixCatsUtils').setup{
	non_nix_value = true
}

local function getlockfilepath()
  if require('nixCatsUtils').isNixCats and type(nixCats.settings.unwrappedCfgPath) == "string" then
    return nixCats.settings.unwrappedCfgPath .. "/lazy-lock.json"
  else
    return vim.fn.stdpath("config") .. "/lazy-lock.json"
  end
end
local lazyOptions = {
  lockfile = getlockfilepath(),
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
}
require('nixCatsUtils.lazyCat').setup(nixCats.pawsible({"allPlugins", "start", "lazy.nvim" }),
{
	-- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
	{ import = 'custom.plugins' },
}, lazyOptions)
