return {
  "tpope/vim-surround",
  "tpope/vim-dispatch",
  -- Lazy
  {
    "vague2k/vague.nvim",
    opts = {},
    lazy = false,
    priority = 100,
    config = function(_, opts)
      require("vague").setup(opts)
      vim.cmd.colorscheme("vague")
    end,
  },
  {
    "direnv/direnv.vim",
    init = function()
      vim.g.direnv_silent_load = 1
    end,
  },
  "echasnovski/mini.ai",
  "adalessa/php-lsp-utils",
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },
  { "nvzone/volt", lazy = true },
  { "nvzone/menu", lazy = true },
}
