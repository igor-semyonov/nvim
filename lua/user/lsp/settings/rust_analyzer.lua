local opts = {
	settings = {
		["rust-analyzer"] = {
			-- Other Settings ...
			cargo = {
				allFeatures = true,
				loadOutDirsFromCheck = true,
				runBuildScripts = true,
			},
			checkOnSave = true,
			-- checkCommand = {
            --     allFeatures = true,
			--     command = "cargo-clippy",
            --     extraArgs = {
            --         "--",
            --         "--no-deps",
            --         "-Dwarnings", --, Promote all warnings to errors
            --         "-Dclippy::correctness",
            --         "-Dclippy::complexity",
            --         "-Dclippy::perf",
            --         "-Dclippy::pedantic",
            --     },
			-- },
			procMacro = {
				enable = true,
				ignored = {
					leptos_macro = {
						-- optional: --
						-- "component",
						"server",
					},
					["async-trait"] = { "async_trait" },
					["napi-derive"] = { "napi" },
					["async-recursion"] = { "async_recursion" },
				},
			},
		},
	},
}

return opts
