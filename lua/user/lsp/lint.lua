-- nvim-lint
local lint = require("lint")
local clippy = lint.linters.clippy
lint.linters_by_ft = {
	markdown = { "vale" },
	rust = { "clippy" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufNew", "InsertLeave" }, {
	callback = function()
		lint.try_lint()
	end,
})

-- ALE
-- local g = vim.g
-- g.ale_linters = {
--     rust = { "cargo" },
--     lua = { "lua_language_server" },
-- }

-- g.ale_ruby_rubocop_auto_correct_all = 1
-- g.ale_virtualtext_cursor = "disabled"
-- g.ale_rust_cargo_subcommand = "clippy"
-- g.ale_rust_cargo_clippy_options = "--all-targets -- -W clippy::all -W clippy::pedantic"
