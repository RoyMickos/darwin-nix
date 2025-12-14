{
  description = "Roys nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # limawm 1.1.1 is broken on mac, fix expected in 1.1.2
    # nixpkgs-old-lima.url = "github:NixOS/nixpkgs/59138c7667b7970d205d6a05a8bfa2d78caa3643";

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
 #      nixpkgs.overlays = [
	# (final: super: {
	#   # Replace 'your-application-name' with the actual package name
	#   # and '.your-application-name' with its attribute path in the old nixpkgs
	#   lima = nixpkgs-old-lima.legacyPackages.${pkgs.system}.pkgs.lima;
	# })
 #      ];
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages =
        [ 
	    # pkgs.aider-chat
	  pkgs.ast-grep
	  pkgs.awscli2
	    # pkgs.aws-sam-cli
	  pkgs.bat
	    #	  pkgs.bitwarden-cli fails
	  pkgs.cowsay
	  pkgs.curlie
	  pkgs.delta
	  pkgs.devcontainer
	  pkgs.difftastic
	  pkgs.direnv
	  pkgs.docker
	  pkgs.fabric-ai
	  pkgs.fd
	  pkgs.figlet
	  pkgs.fzf
	  pkgs.gawk
	  pkgs.gemini-cli-bin
	  pkgs.glow
	  pkgs.gnupg
	  pkgs.go
	  pkgs.google-cloud-sdk
	  pkgs.graphicsmagick
	  pkgs.graphviz
	  pkgs.grpcurl
	  pkgs.htop
	  pkgs.jq
	  pkgs.kanata
	  pkgs.lazygit
	  pkgs.lf
	  pkgs.lima
	  pkgs.lsd
	  pkgs.luajitPackages.luarocks
	  pkgs.marksman
	  pkgs.marp-cli
	  pkgs.mkalias
	    # pkgs.mutagen
	  pkgs.neofetch
	  pkgs.neovim
	  pkgs.opencode
	  pkgs.pass
	  pkgs.plantuml
	  pkgs.pipx
	  pkgs.podman
	  pkgs.podman-compose
	  pkgs.podman-tui
	  pkgs.postgresql
	  pkgs.pwgen
	  pkgs.ripgrep
	  pkgs.scc
	  pkgs.sops
	  pkgs.sox
	  pkgs.sshs
	  pkgs.ssm-session-manager-plugin  # session manager plugin for aws cli
	  pkgs.starship
	  pkgs.stow
	  pkgs.taskwarrior3
	  pkgs.taskwarrior-tui
	  pkgs.termshark
	  pkgs.tig
	  pkgs.timewarrior
	  pkgs.tldr
	  pkgs.tree
	  pkgs.tmux
	  pkgs.uv
	  pkgs.zoxide
        ];

      fonts.packages = [
	pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.hack
      ];

      # ui apps are best installed through homebrew so that they appear in spotlight
      homebrew = {
        enable = true;
	brews = [
	  "asdf"
          "mas"
	];
	taps = [
          "homebrew/core"
          "homebrew/cask"
        ];
	casks = [
	  "1Password"
	  "1Password-cli"
          "alacritty"
	  "anki"
	  "bitwarden"
	  "chromedriver"
	  "drawio"
	  "gimp"
	  "karabiner-elements"
	  "obsidian"
	  "podman-desktop"
	  "raycast"
	  "telegram"
	];
	masApps = {
          # "Xcode" = 497799835;
	};
	onActivation.autoUpdate = true;
	onActivation.upgrade = true;
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
     
      system.primaryUser = "roy.mickos";
    
      system.defaults = {
        dock.autohide = true;
	dock.persistent-apps = [
	  "/System/Applications/Launchpad.app"
          "Applications/Alacritty.app"
	  "/Applications/Obsidian.app"
	  "/Applications/Anki.app"
	  "/Applications/Safari.app"
	  "/System/Applications/Mail.app"
	  "/System/Applications/Calendar.app"
	  "/Applications/Slack.app"
	];
	# for aerospace
	spaces.spans-displays = true;
	NSGlobalDomain.AppleICUForce24HourTime = true;
	finder.FXPreferredViewStyle = "clmv";
      };

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
