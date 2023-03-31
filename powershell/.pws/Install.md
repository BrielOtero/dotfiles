```
winget install XP8K0HKJFRXGCK
```

```
oh-my-posh version
```

```
code $profile
```

And add into the file 

```
. $env:USERPROFILE\.pws\id.ps1
```

```
Install-Module Terminal-Icons -Scope CurrentUser
```

```
Install-Module posh-git -Scope CurrentUser -Force
```

```
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
```

```
Set-PSReadLineOption -PredictionSource History
```

```
iwr -useb get.scoop.sh | iex
```

```
scoop install fzf
```

```
Install-Module -Name PSFzf -Scope CurrentUser -Force
```
