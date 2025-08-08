local servers = {
    "cmake",
    -- "rust_analyzer",
    "hyprls",
    "clangd",
    "lua_ls",
    "ast_grep",
    -- "nil_ls",

    -- "pyright",
    "pylsp",
    "ruff",

    "bashls",
    -- "yamlls",
    "jsonls",
    "awk_ls",
    "docker_compose_language_service",
    "html",
    -- "ltex",
    "ltex_plus",
    "texlab",
    "matlab_ls",
    "julials",
    -- "hdl_checker",
}

local settings = {
    ui = {
        border = "rounded",
        icons = {
            package_installed = "◍",
            package_pending = "◍",
            package_uninstalled = "◍",
        },
    },
    log_level = vim.log.levels.INFO,
    max_concurrent_installers = 6,
}

require("mason").setup(settings)
-- require("mason-lspconfig").setup({
--     ensure_installed = servers,
--     -- automatic_installation = true,
--     automatic_installation = { exclude = servers_no_auto_install },
-- })

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
    return
end

-- vim.list_extend(servers, servers_no_auto_install)

local opts = {}
-- local servers = vim.tbl_extend("force", { "vhdl_ls" }, servers)

for _, server in pairs(servers) do
    opts = {
        on_attach = require("user.lsp.handlers").on_attach,
        capabilities = require("user.lsp.handlers").capabilities,
    }

    server = vim.split(server, "@")[1]

    local require_ok, conf_opts = pcall(require, "user.lsp.settings." .. server)
    if require_ok then
        opts = vim.tbl_deep_extend("force", conf_opts, opts)
    end

    lspconfig[server].setup(opts)
end

local lspconfig = require("lspconfig")
local opts = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
}
-- lspconfig["vhdl_ls"].setup(opts)


require("lspconfig").nixd.setup({
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
    cmd = { "nixd" },
    settings = {
        nixd = {
            nixpkgs = {
                expr = "import <nixpkgs> { }",
            },
            formatting = {
                command = { "alejandra" }, -- or nixfmt or nixpkgs-fmt
            },
            -- options = {
            --   nixos = {
            --       expr = '(builtins.getFlake "/PATH/TO/FLAKE").nixosConfigurations.CONFIGNAME.options',
            --   },
            --   home_manager = {
            --       expr = '(builtins.getFlake "/PATH/TO/FLAKE").homeConfigurations.CONFIGNAME.options',
            --   },
            -- },
        },
    },
})
