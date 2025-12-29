function base64encode {
    param([string]$inputString)
    $encoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($inputString))
    Write-Output $encoded
}

function base64decode {
    param([string]$base64string)
    $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64string))
    Write-Output $decoded
}

function base64encode-file {
    # Check if the user provided a file path as an argument

    if ($args.Length -eq 0) {
        Write-Host "Usage: .\EncodeFile.ps1 <path_to_file>"
        return
    }

    # Get the relative file path from the command line argument
    $filePath = $args[0]

    # Get the current working directory (relative path will be from here)
    $currentDirectory = Get-Location

    # Combine the current directory with the relative file path
    $fullFilePath = Join-Path $currentDirectory $filePath

    # Check if the file exists
    if (-Not (Test-Path $fullFilePath)) {
        Write-Host "The file '$fullFilePath' does not exist."
        return
    }

    # Read the file content as bytes
    $fileBytes = [System.IO.File]::ReadAllBytes($fullFilePath)

    # Encode the byte array to Base64
    $encodedBase64 = [Convert]::ToBase64String($fileBytes)

    # Output the Base64 string to a file or the console
    $encodedBase64 | Out-File "$fullFilePath.base64"  # Saves the Base64 to a file with the same name + .base64 extension

    Write-Host "Base64 encoded file saved to '$fullFilePath.base64'"
}

function base64decode-file {
    # Check if the user provided a Base64 file path as an argument

    if ($args.Length -eq 0) {
        Write-Host "Usage: .\DecodeFile.ps1 <path_to_base64_file>"
        return
    }

    # Get the relative file path of the Base64 file from the command line argument
    $base64FilePath = $args[0]

    # Get the current working directory (relative path will be from here)
    $currentDirectory = Get-Location

    # Combine the current directory with the relative Base64 file path
    $fullBase64FilePath = Join-Path $currentDirectory $base64FilePath

    # Check if the Base64 file exists
    if (-Not (Test-Path $fullBase64FilePath)) {
        Write-Host "The file '$fullBase64FilePath' does not exist."
        return
    }

    # Read the Base64 encoded content from the file
    $encodedBase64 = Get-Content $fullBase64FilePath -Raw

    # Decode the Base64 content to bytes
    $fileBytes = [Convert]::FromBase64String($encodedBase64)

    # Determine the output file name by removing the ".base64" extension
    $outputFilePath = $fullBase64FilePath.Substring(0, $fullBase64FilePath.Length - 7)  # Remove .base64 from the end

    # Write the decoded bytes to the output file
    [System.IO.File]::WriteAllBytes($outputFilePath, $fileBytes)

    Write-Host "Decoded file saved to '$outputFilePath'"
}