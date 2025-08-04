return {
    {
        "mrcjkb/rustaceanvim",
        version = "^5", -- Recommended
        -- enabled = false,
        ft = { "rust" },
        init = function()
            local opts = {
                on_attach = require("user.lsp.handlers").on_attach,
                capabilities = require("user.lsp.handlers").capabilities,
            }
            local require_ok, conf_opts = pcall(require, "user.lsp.settings.rust_analyzer")
            if require_ok then
                opts = vim.tbl_deep_extend("force", conf_opts, opts)
            end
            vim.g.rustaceanvim = {
                server = opts,
            }
        end,
    },
}
