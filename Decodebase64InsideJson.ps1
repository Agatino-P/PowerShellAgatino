$json= Get-Content ./base64.json | ConvertFrom-Json 
foreach ($item in $json) {
   $item.text = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($item.text))
}
$json | ConvertTo-Json -Depth 10 | Set-Content -Path "./data.json"

$json