{
  description = "Roys nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew, homebrew-core, homebrew-cask }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages =
        [ 
	  pkgs.mkalias
	  pkgs.neovim
	  pkgs.stow
	  pkgs.tmux
        ];

      fonts.packages = [
	pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.hack
      ];

      # ui apps are best installed through homebrew so that they appear in spotlight
      homebrew = {
        enable = true;
	brews = [
          "mas"
	];
	casks = [
          "alacritty"
	  "anki"
	  "obsidian"
	  "slack"
	  "telegram"
	];
	masApps = {
          # "Xcode" = 497799835;
	};
      };

      system.activationScripts.applications.text = ''
	mkdir -p /Applications/Nix\ Apps
	chflags norestricted /Applications/Nix\ Apps
      '';

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#R5419
    darwinConfigurations."R5419" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
	mac-app-util.darwinModules.default
	nix-homebrew.darwinModules.nix-homebrew
	{
          nix-homebrew = {
            enable = true;
	    enableRosetta = true;
	    user = "roy.mickos";
	    taps = {
              "homebrew/homebrew-core" = homebrew-core;
	      "homebrew/homebrew-cask" = homebrew-cask;
	    };
	    mutableTaps = false;
	  };
	}
      ];
    };
  };
}
