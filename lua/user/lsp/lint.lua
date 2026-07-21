-- nvim-lint
local lint = require("lint")
local nix = require("user.nix")

-- Linters keyed by filetype, each gated on the nix toggle that provisions its
-- binary. When that toggle is off (under nix) the linter is dropped so we don't
-- shell out to a missing executable on every save. NOTE: vale also needs a
-- `.vale.ini` to do anything — none exists yet, so markdown linting is inert
-- until one is added.
lint.linters_by_ft = {}
for ft, spec in pairs({
	markdown = { linter = "vale", kind = "languages", key = "latex" },
	rust = { linter = "clippy", kind = "languages", key = "rust" },
}) do
	if nix.enabled(spec.kind, spec.key) then
		lint.linters_by_ft[ft] = { spec.linter }
	end
end

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
