function Remove-GitGoneBranches {
    [CmdletBinding()]
    param(
        [switch]$DryRun
    )

    $filter = 'gone\]'

    git fetch --prune
    git switch main
    git pull --ff-only

    $current = (git branch --show-current) 2>$null

    "All branches: $(git branch -vv)"
    "Filter: $($filter)"

    $targets =
    git branch -vv        |
    Select-String $filter |
    ForEach-Object {
        # branch name is 2nd token on the line
        ($_ -split '\s+')[1]
    }                     |
    Where-Object { $_ -and $_ -ne $current }

    "Target brances:"
    $targets

    if ($DryRun) {
        return
    }

    foreach ($b in $targets) {
        git branch -D $b | Out-Host
    }
}

