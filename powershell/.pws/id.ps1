
# Aliases
Set-Alias vim nvim
Set-Alias ll ls
Set-Alias g git
Set-Alias tt tree

#oh-my-posh
oh-my-posh init pwsh --config 'C:\Users\ID\.pws\id.omp.json' | Invoke-Expression

# Fzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Env
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"

# Terminal Icons
Import-Module -Name Terminal-Icons

# PSReadLine
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineOption -PredictionViewStyle InlineView


# Utilities
function where ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

