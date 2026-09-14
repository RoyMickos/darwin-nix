{
  description = "Roys nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    workmux.url = "github:raine/workmux";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-homebrew.inputs.brew-src.follows = "brew-src";
    nix-homebrew.inputs.homebrew-core.follows = "homebrew-core";
    nix-homebrew.inputs.homebrew-cask.follows = "homebrew-cask";
    brew-src = {
      url = "github:Homebrew/brew";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-hunk = {
      url = "github:modem-dev/homebrew-tap";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew, brew-src, homebrew-core, homebrew-cask, homebrew-hunk, workmux }:
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
	  pkgs.ast-grep
	  pkgs.age
	  pkgs.asdf-vm
	  pkgs.awscli2
	  pkgs.bat
	  pkgs.bun
	  pkgs.claude-code
	  pkgs.cowsay
	  pkgs.curlie
	  pkgs.delta
	  pkgs.devcontainer
	  pkgs.difftastic
	  pkgs.direnv
	  pkgs.docker
	  pkgs.docker-sbx
	  pkgs.efm-langserver
	  pkgs.fabric-ai
	  pkgs.fastfetch
	  pkgs.fd
	  pkgs.figlet
	  pkgs.fzf
	  pkgs.gawk
	  # pkgs.gemini-cli-bin
	  pkgs.gh
	  pkgs.ghostty-bin
	  pkgs.glow
	  pkgs.gnupg
	  pkgs.go
	  pkgs.google-cloud-sdk
	  pkgs.graphicsmagick
	  pkgs.graphviz
	  pkgs.grpcurl
	  pkgs.htop
	  pkgs.jq
	  pkgs.k9s
	  pkgs.kanata
	  pkgs.kubectl
	  pkgs.kustomize
	  pkgs.lazygit
	  pkgs.lf
	  pkgs.lima
	  pkgs.lsd
	  pkgs.luajitPackages.luarocks
	  pkgs.marksman
	  pkgs.marp-cli
    pkgs.mise
	  pkgs.mkalias
	  pkgs.neovim
	  pkgs.opencode
	  pkgs.pass
	  pkgs.plantuml
	  pkgs.pi-coding-agent
	  pkgs.pipx
	  pkgs.podman
	  pkgs.podman-compose
	  pkgs.podman-tui
	  pkgs.postgresql
	  pkgs.pwgen
	  pkgs.ripgrep
    pkgs.rustup
	  pkgs.scc
	  pkgs.sops
	  pkgs.sox
	  pkgs.sshs
	  pkgs.ssm-session-manager-plugin  # session manager plugin for aws cli
	  pkgs.starship
	  pkgs.stow
	  pkgs.taskwarrior3
	  pkgs.taskwarrior-tui
	  pkgs.television
	  pkgs.termshark
	  pkgs.tig
	  pkgs.timewarrior
	  pkgs.tldr
	  pkgs.tree
	  pkgs.tree-sitter
	  pkgs.tmux
	  pkgs.tuicr
	  pkgs.uv
	  pkgs.upcloud-cli
	  pkgs.wget
	  workmux.packages.${pkgs.system}.default
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
	  "herdr"
    "hunk"
    "mas"
	];
	taps = [
  "homebrew/core"
  "homebrew/cask"
  ];
	casks = [
	  "1Password"
	  "1Password-cli"
	  "anki"
	  "bitwarden"
	  "chromedriver"
	  "drawio"
	  "firefox"
	  "gimp"
	  "karabiner-elements"
	  "little-snitch"
	  "obsidian"
	  "podman-desktop"
	  "rancher"
	  "raycast"
	  "telegram"
	  "vmlx"
    "alacritty"
    "hammerspoon"
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

      # Deduplicate identical files in /nix/store
      nix.settings.auto-optimise-store = true;

      # Optional but useful: avoid keeping unnecessary outputs
      nix.settings.keep-outputs = false;
      nix.settings.keep-derivations = false;

      nix.settings.download-buffer-size = 134217728; # 128 MB
	
      # Garbage collection
      nix.gc = {
	automatic = true;

	# Weekly cleanup (low friction)
	interval = { Weekday = 0; Hour = 3; Minute = 0; };

	# Keep only recent stuff
	options = "--delete-older-than 7d";
      };

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;
      programs.zsh.enable = true;

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
	      "modem-dev/homebrew-tap" = homebrew-hunk;
	    };
	    mutableTaps = false;
	  };
	}
      ];
    };
  };
}
