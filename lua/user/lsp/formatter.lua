require("conform").setup({
    -- Define your formatters
    formatters_by_ft = {
        lua = { "stylua" },
        yaml = { "yamlfmt" },
        c = { "clang-format" },
        xml = {"xmlformat"},
        python = { "isort", "black" },
        cmake = { "gersemi" },
        rust = { "rustfmt" },
        --             function()
        --                 if vim.fn.executable("leptosfmt") == 0 then
        --                     return require("formatter.filetypes.rust").rustfmt()
        --                 end
        --                 return {
        --                     exe = "leptosfmt",
        --                     args = {
        --                         "--stdin",
        --                         "--rustfmt",
        --                         "--tab-spaces 4",
        --                         "--max-width 42",
        --                     },
        --                     stdin = true,
        --                 }
        --             end,
        toml = { "taplo" },
        tex = { "latexindent" },
        nix = { "alejandra" }
    },
    -- Set up format-on-save
    -- format_on_save = { timeout_ms = 500, lsp_fallback = true },
    -- Customize formatters
    formatters = {
        shfmt = {
            prepend_args = { "-i", "2" },
        },
    },
})

vim.keymap.set(
    "n",
    "<leader>f",
    function()
        require("conform").format({ async = true, lsp_fallback = true })
    end,
    {
        desc = "Format buffer",
    }
)

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
