function refreshenv {
    # 1. Update System (Machine) Variables
    $machineVars = [System.Environment]::GetEnvironmentVariables('Machine')
    foreach ($key in $machineVars.Keys) {
        [System.Environment]::SetEnvironmentVariable($key, $machineVars[$key], 'Process')
    }

    # 2. Update User Variables
    $userVars = [System.Environment]::GetEnvironmentVariables('User')
    foreach ($key in $userVars.Keys) {
        if ($key -eq 'Path') {
            # Append User path to the System path we just set
            $env:Path = $env:Path + ";" + $userVars[$key]
        } else {
            [System.Environment]::SetEnvironmentVariable($key, $userVars[$key], 'Process')
        }
    }
    
    Write-Host "Environment variables have been refreshed." -ForegroundColor Green
}