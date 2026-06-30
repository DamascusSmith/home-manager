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
