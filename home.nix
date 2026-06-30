{ config, pkgs, username, homeDirectory, oldPkgs, nixgl, ... }:
let
	ghostty = config.lib.nixGL.wrap pkgs.ghostty;

	resurrect = pkgs.tmuxPlugins.resurrect;

	tmuxResurrectSave = pkgs.writeShellScript "tmux-resurrect-save" ''
		set -eu

		# No tmux server is running, so there is nothing to save
		if ! ${pkgs.tmux}/bin/tmux list-sessions >/dev/null 2>&1; then
			exit 0
		fi

		# Prevent simultaneous saves.
		lock_file="''${XDG_RUNTIME_DIR:-/tmp}/tmux-resurrect-save.lock"

		${pkgs.util-linux}/bin/flock -n "$lock_file" \
			${pkgs.tmux}/bin/tmux run-shell \
			"${resurrect}/share/tmux-plugins/resurrect/scripts/save.sh"
		'';
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
	home.username = username;
	home.homeDirectory = homeDirectory;

	targets.genericLinux.enable = true;

	targets.genericLinux.nixGL = {
		packages = nixgl.packages;
		defaultWrapper = "mesa";
	};

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
		pkgs.btop
		ghostty
    oldPkgs.neovim
		pkgs.tmux
		pkgs.git
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

	xdg.desktopEntries."com.mitchellh.ghostty" = {
		name = "Ghostty";
		genericName = "Terminal Emulator";
		comment = "A fast, feature-rich terminal emulator";

		exec = "${ghostty}/bin/ghostty --gtk-single-instance=true";

		icon = "com.mitchellh.ghostty";
		terminal = false;
		startupNotify = true;

		categories = [
			"System"
			"TerminalEmulator"
		];

		settings = {
			DBusActivatable = "false";
		};
	};

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
		"foo.txt".text = "bar";
		"example.config".source = ./config.txt;
		".config/ghostty/config.ghostty".source = ./config/config.ghostty;
		".config/nvim" = {
			source = ./config/nvim;
			recursive = true;
		};

    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/damascussmith/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };
	
	#Programs
	programs.tmux = {
		enable = true;
		mouse = true;
		
		plugins = with pkgs.tmuxPlugins; [
			{
				plugin = resurrect;
				extraConfig = builtins.readFile ./config/tmux/plugins/resurrect.conf;
			}

			{
				plugin = continuum;
				extraConfig = builtins.readFile ./config/tmux/plugins/continuum.conf;
			}
		];

		extraConfig = builtins.readFile ./config/tmux/tmux.conf;
	};

	programs.git = {
		enable = true;

		settings = {
			user = {
				name = "William Wickenden";
				email = "121053218+DamascusSmith@users.noreply.github.com";
			};

			init.defaultBranch = "main";
			pull.rebase = false;
			push.autoSetupRemote = true;
		};
	};

	#Systemd

	systemd.user.services.tmux-resurrect-save = {
		Unit = {
			Description = "Save tmux sessions with tmux-resurrect";
		};

		Service = {
			Type = "oneshot";
			ExecStart = tmuxResurrectSave;
		};
	};

	systemd.user.timers.tmux-resurrect-save = {
		Unit = {
			Description = "Save tmux sessions every five minutes";
		};

		Timer = {
			OnBootSec = "2min";
			OnUnitActiveSec = "5min";
			AccuracySec = "10s";
			Persistant = true;
			Unit = "tmux-resurrect-save.service";
		};

		Install = {
			WantedBy = [ "timers.target" ];
		};
	};

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
