return { -- LSP Configuration & Plugins
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "williamboman/mason.nvim",
      enabled = require("nixCatsUtils").lazyAdd(true, false),
      config = true,
    },
    { "williamboman/mason-lspconfig.nvim", enabled = require("nixCatsUtils").lazyAdd(true, false) },
    { "WhoIsSethDaniel/mason-tool-installer.nvim", enabled = require("nixCatsUtils").lazyAdd(true, false) },
    { "j-hui/fidget.nvim", opts = {} },

    -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          -- adds type hints for nixCats global
          { path = (require("nixCats").nixCatsPath or "") .. "/lua", words = { "nixCats" } },
        },
      },
    },
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("gd", require("snacks").picker.lsp_definitions, "[G]oto [D]efinition")
        map("gr", require("snacks").picker.lsp_references, "[G]oto [R]eferences")
        map("gI", require("snacks").picker.lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>D", require("snacks").picker.lsp_type_definitions, "Type [D]efinition")
        map("<leader>ds", require("snacks").picker.lsp_symbols, "[D]ocument [S]ymbols")
        map("<leader>ws", require("snacks").picker.lsp_workspace_symbols, "[W]orkspace [S]ymbols")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
        -- will be done with conform
        -- map("<leader>f", vim.lsp.buf.format, "[F]ormat the document")

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
            end,
          })
        end

        -- The following autocommand is used to enable inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, "[T]oggle Inlay [H]ints")
        end
      end,
    })

    -- LSP servers and clients are able to communicate to each other what features they support.
    --  By default, Neovim doesn't support everything that is in the LSP specification.
    --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
    --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
    -- local capabilities = vim.lsp.protocol.make_client_capabilities()
    -- -- FIX re enable if cmp added
    -- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    --  Add any additional override configuration in the following tables. Available keys are:
    --  - cmd (table): Override the default command used to start the server
    --  - filetypes (table): Override the default list of associated filetypes for the server
    --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    --  - settings (table): Override the default settings passed when initializing the server.
    --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
    -- NOTE: nixCats: there is help in nixCats for lsps at `:h nixCats.LSPs` and also `:h nixCats.luaUtils`
    local servers = {}
    -- servers.clangd = {},
    -- servers.pyright = {},
    -- servers.rust_analyzer = {},
    -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
    --
    -- Some languages (like typescript) have entire language plugins that can be useful:
    --    https://github.com/pmizio/typescript-tools.nvim
    --
    -- But for many setups, the LSP (`tsserver`) will work just fine
    -- servers.tsserver = {},
    --

    -- NOTE: nixCats: nixd is not available on mason.
    if require("nixCatsUtils").isNixCats then
      servers.nixd = {}
    else
      servers.rnix = {}
      servers.nil_ls = {}
    end
    servers.lua_ls = {
      -- cmd = {...},
      -- filetypes = { ...},
      -- capabilities = {},
      settings = {
        Lua = {
          completion = {
            callSnippet = "Replace",
          },
          -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
          diagnostics = {
            globals = { "nixCats" },
            disable = { "missing-fields" },
          },
        },
      },
    }

    if require("nixCatsUtils").enableForCategory("laravel") then
      servers.phpactor = {
        init_options = {
          ["language_server_configuration.auto_config"] = false,
          ["language_server_worse_reflection.inlay_hints.enable"] = true,
          ["language_server_worse_reflection.inlay_hints.types"] = false,
          ["language_server_worse_reflection.inlay_hints.params"] = true,
          ["code_transform.import_globals"] = false,
          ["indexer.exclude_patterns"] = {
            "/vendor/**/Tests/**/*",
            "/vendor/**/tests/**/*",
            "/vendor/composer/**/*",
            "/vendor/laravel/fortify/workbench/**/*",
            "/vendor/filament/forms/.stubs.php",
            "/vendor/filament/notifications/.stubs.php",
            "/vendor/filament/tables/.stubs.php",
            "/vendor/filament/actions/.stubs.php",
            "/storage/framework/cache/**/*",
            "/storage/framework/views/**/*",
            "vendor/kirschbaum-development/eloquent-power-joins/.stubs.php",
          },
          ["php_code_sniffer.enabled"] = false,

          ["language_server_phpstan.enabled"] = true,
          ["language_server_phpstan.level"] = "5",
          ["language_server_phpstan.bin"] = "%project_root%/vendor/phpstan",
          ["language_server_phpstan.mem_limit"] = "2048M",
        },
      }
    end

    if require("nixCatsUtils").enableForCategory("symfony") then
      servers.phpactor = {
        init_options = {
          ["language_server_configuration.auto_config"] = false,
          ["language_server_worse_reflection.inlay_hints.enable"] = true,
          ["language_server_worse_reflection.inlay_hints.types"] = false,
          ["language_server_worse_reflection.inlay_hints.params"] = true,
          ["code_transform.import_globals"] = true,
          ["phpunit.enabled"] = true,
          ["indexer.exclude_patterns"] = {
            "/vendor/**/Tests/**/*",
            "/vendor/**/tests/**/*",
            "/var/cache/**/*",
            "/vendor/composer/**/*",
          },
          ["php_code_sniffer.enabled"] = true,
          ["php_code_sniffer.bin"] = "%project_root%/bin/phpcs",

          ["language_server_phpstan.enabled"] = true,
          ["language_server_phpstan.level"] = "7",
          ["language_server_phpstan.bin"] = "%project_root%/bin/phpstan",
          ["language_server_phpstan.mem_limit"] = "2048M",
        },
      }
    end

    if require("nixCatsUtils").enableForCategory("go") then
      servers.gopls = {}
    end

    -- NOTE: nixCats: if nix, use lspconfig instead of mason
    -- You could MAKE it work, using lspsAndRuntimeDeps and sharedLibraries in nixCats
    -- but don't... its not worth it. Just add the lsp to lspsAndRuntimeDeps.
    if require("nixCatsUtils").isNixCats then
      for server_name, _ in pairs(servers) do
        require("lspconfig")[server_name].setup({
          capabilities = capabilities,
          settings = servers[server_name],
          init_options = (servers[server_name] or {}).init_options,
          filetypes = (servers[server_name] or {}).filetypes,
          cmd = (servers[server_name] or {}).cmd,
          root_pattern = (servers[server_name] or {}).root_pattern,
        })
      end
    else
      -- NOTE: nixCats: and if no nix, do it the normal way

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require("mason").setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua", -- Used to format Lua code
        "blade-formatter", -- Used to format Blade code
        "goimports",
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end
  end,
}
