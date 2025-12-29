Update-FormatData -PrependPath "$HOME/.config/powershell/FileInfo.MB.format.ps1xml"

Set-Alias k kubectl

Import-Module PSReadLine

Set-PSReadLineOption -Colors @{ InlinePrediction = '#00A000'}

Import-Module PSReadLine

Set-PSReadLineOption -Colors @{ InlinePrediction = '#00A000'}

0 references
function EditProfileFunc {Start-Process -FilePath "C:\Program Files\Notepad++\notepad++.exe" -ArgumentList $Profile}
set-Alias Edit-Profile EditProfileFunc

0 references
function SetTitleFunc ([string] $NewTitle) {$host.UI.RawUI.WindowTitle = $NewTitle}
set-Alias Set-Title SetTitleFunc


