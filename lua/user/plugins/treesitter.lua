return {
	{
		"nvim-treesitter/nvim-treesitter",
		init = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
		config = {
			ensure_installed = {
				"c",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"rust",
				"toml",
				"yaml",
				"python",
				"json",
				"latex",
				"matlab",
				"bash",
                "json",
                "nix",
			},
			sync_install = false,
			auto_install = true,
			ignore_install = { "javascript" },
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
			-- rainbow = {
			--     enable = true,
			--     extended_mode = true,
			--     max_file_lines = nil,
			-- }
		},
	},
}
