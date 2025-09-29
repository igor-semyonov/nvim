local username = vim.fn.getenv("USER")
local hostname = vim.loop.os_gethostname()
local flake_path = "/home/" .. username .. "/.config/nix-config/"
local expr_nixos = "(builtins.getFlake flake_path).nixosConfigurations." .. hostname .. ".options"
local expr_homemanager = "(builtins.getFlake flake_path).homeConfigurations."
	.. '"'
	.. username
	.. "@"
	.. hostname
	.. '".options'
local nixd_opts = {
	cmd = { "nixd" },
	settings = {
		nixd = {
			nixpkgs = {
				expr = "import <nixpkgs> { }",
			},
			formatting = {
				command = { "alejandra" }, -- or nixfmt or nixpkgs-fmt
			},

			options = {
				nixos = {
					expr = expr_nixos,
				},
				home_manager = {
					expr = expr_homemanager,
				},
			},
		},
	},
}
return nixd_opts
