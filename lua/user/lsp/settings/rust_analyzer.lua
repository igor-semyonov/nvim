local opts = {
	cmd = { vim.fn.expand("$HOME/.cargo/bin/rust-analyzer") },
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
