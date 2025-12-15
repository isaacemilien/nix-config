{config, pkgs, ... }:

{
	home.username = "alice";
	home.homeDirectory = "/home/alice";

	programs.bash = {
		enable = true;
		initExtra = builtins.readFile ./dotfiles/.bashrc;
	};

	programs.vim = {
		enable = true;
		extraConfig = builtins.readFile ./dotfiles/.vimrc;
	};
	
	programs.tmux = {
		enable = true;
		extraConfig = builtins.readFile ./dotfiles/.tmux.conf;
	};

	home.stateVersion = "26.05";
}
