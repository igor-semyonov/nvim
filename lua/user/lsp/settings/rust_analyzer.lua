local opts = {
	settings = {
		["rust-analyzer"] = {
			-- Other Settings ...
			procMacro = {
				ignored = {
					leptos_macro = {
						-- optional: --
						-- "component",
						"server",
					},
				},
			},
		},
	},
}

return opts
