return {
	{
		"tpope/vim-surround",
        -- enabled = false,
	},
	{
		"jiangmiao/auto-pairs",
        -- enabled = false,
	},
	{
		"hiphish/rainbow-delimiters.nvim",
        -- enabled = false,
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")

			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					vim = rainbow_delimiters.strategy["local"],
				},
				query = {
					[""] = "rainbow-delimiters",
					lua = "rainbow-blocks",
				},
				highlight = {
					-- 'RainbowDelimiterRed',
					"RainbowDelimiterYellow",
					"RainbowDelimiterBlue",
					"RainbowDelimiterOrange",
					"RainbowDelimiterGreen",
					-- 'RainbowDelimiterViolet',
					-- 'RainbowDelimiterCyan',
				},
			}
		end,
	},
}
