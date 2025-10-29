{pkgs, ...}:
pkgs.vimUtils.buildVimPlugin {
  name = "nvim-lsp-endhints";
  src = pkgs.fetchFromGitHub {
    owner = "chrisgrieser";
    repo = "nvim-lsp-endhints";
    rev = "d4ea1bf2dcbe1c4d522e2c06953988993a9acdf1";
    hash = "sha256-nRL3ReIBHuOZn09tjlIL6C2Zlj7oooUTPtrjKPUDTJc=";
  };
}
