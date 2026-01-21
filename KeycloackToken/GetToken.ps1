Clear-Host

$keycloackCurlUrl = "https://auth.cb-wo-keycloak-t1.test.g-itsrv.cloud/auth/realms/test-t3/protocol/openid-connect/token"
$keycloackCurlArguments = @(
    "-k", "-L", "-s",    
    "-H", "Content-Type: application/x-www-form-urlencoded",
    "--data-urlencode", "grant_type=client_credentials",
    "--data-urlencode", "client_id=ba-wo-bsl-t3-gateway-api",
    "--data-urlencode", "client_secret=XdTIJJZmUUxcerfRHbOu0DkJyCYzZ8Jz",
    $keycloackCurlUrl
)

$keycloackResponse = & curl.exe $keycloackCurlArguments
$keycloack = $keycloackResponse | ConvertFrom-Json 
"`n---------`n`n$($keycloack|ConvertTo-Json)`n`n---------`n"
$accessToken = $keycloack.access_token
$accessToken

$accessToken | Set-Content -Path "token.txt" -NoNewline -Force
Write-Host "You can now edit 'token.txt'. Press Enter to continue..." -ForegroundColor Cyan; Pause
$accessToken = (Get-Content -Path "token.txt" -Raw).Trim()

$orderCode = Read-Host -Prompt "Please enter the Order Code"

$payloadJson= @{
    orderCode = $orderCode
    type      = "BankTransfer"
} | ConvertTo-Json -Compress

# 2. Define Arguments Array
# By wrapping the arguments in @(...), we ensure PowerShell treats them as literal strings
# and passes them exactly as-is to the executable, avoiding quote-parsing errors.
$curlArguments = @(
    "-k", "-L", "-s",
    'https://gateway-api-b1.ba-wo-bsl-t3.ittest.cornerbanca.local/api/clanq/v2/payments/Authorization/payment/6d3a8d55-113f-4505-b60c-606ec90bf936',
    "-H", "accept: application/json",
    "-H", "Accept-Language: it",
    "-H", "X-ProductName: Keycloak",
    "-H", 'X-B3-TraceId: 3df796b1-4064-4ece-aa3d-cd754f93d782' 
    "-H", "Authorization: Bearer $accessToken",
    #"-H", "X-AuthSessionId: $authSession",
    "-H", 'Content-Type: application/json'
    "-d", $payloadJson
)
$curlArguments | ConvertTo-Json
# 3. Execution
# We use the Call Operator (&) to run the string "curl" with the array of arguments.
$response = & curl.exe $curlArguments
"`n---------`n`n$($response|ConvertFrom-Json|ConvertTo-Json)`n`n---------`n"