## Install and Setup
Run this command to get the install script and run it, and you should be good to go
```
curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/DamascusSmith/home-manager/main/setup-home-manager.sh | bash
```
NOTE: This is intended to be used on fresh systems so if you have already installed configurations for programs like nvim you may run into issues

### Making changes
Note your going to want to run;
```
home-manager switch --impure --flake .#wikkenden-home
```

As opposed to:
```
home-manager switch --flake .#wikkenden-home
```

As ```--impure``` allows nix to read ```"$USER"``` and ```"$HOME"``` so that it will adapt no matter the system for installations/setup
