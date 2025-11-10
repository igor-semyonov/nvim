local opts = {
	filetypes = {
		"aspnetcorerazor",
		"astro",
		"astro-markdown",
		"blade",
		"clojure",
		"django-html",
		"htmldjango",
		"edge",
		"eelixir",
		"elixir",
		"ejs",
		"erb",
		"eruby",
		"gohtml",
		"gohtmltmpl",
		"haml",
		"handlebars",
		"hbs",
		"html",
		"htmlangular",
		"html-eex",
		"heex",
		"jade",
		"leaf",
		"liquid",
		"markdown",
		"mdx",
		"mustache",
		"njk",
		"nunjucks",
		"php",
		"razor",
		"slim",
		"twig",
		"css",
		"less",
		"postcss",
		"sass",
		"scss",
		"stylus",
		"sugarss",
		"javascript",
		"javascriptreact",
		"reason",
		"rescript",
		"typescript",
		"typescriptreact",
		"vue",
		"svelte",
		"templ",
		"rust",
	},
	settings = {
		tailwindCSS = {
			includeLanguages = {
				rust = "html", -- Treat rust files as html for Tailwind CSS purposes
			},
			experimental = {
				classRegex = {
					'class\\s*=\\s*"([^"]*)"', -- Basic regex for class attributes
					'class!\\s*=\\s*"([^"]*)"',
					'rsx!\\s*\\{.*class:\\s*"([^"]*)".*\\}', -- For Dioxus RSX syntax
					-- Add other regex if you use different ways of defining classes in your Dioxus components
				},
			},
		},
	},
}

return opts
