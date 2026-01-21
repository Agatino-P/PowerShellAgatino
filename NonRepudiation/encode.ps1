# Input Data
$payload = Get-Content -Path ".\payload.txt"

$iat=[DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$iatKVP='"http://fm.bottomline.com/iat": {0}' -f $iat

$crit=@'
"crit":[
    "b64",
    "http://fm.bottomline.com/version",
    "http://fm.bottomline.com/iat",
    "http://fm.bottomline.com/iss"
]
'@

$headerFields = @(
    '"alg":"PS256"',
    '"typ":"JOSE"',
    '"kid":"9657693A8580243F35BBDE565F6B4814AF549E75"',
    '"b64": false',
    $iatKVP,
    '"http://fm.bottomline.com/iss":"CN=TestCert"',
    '"http://fm.bottomline.com/version":"v2"',
    $crit
)
$header = '{' + ($headerFields -join ',') + '}'

# --- REPLACE THIS SECTION ---
# OLD: $rsa = [System.Security.Cryptography.RSA]::Create(2048)

# NEW: Load from your OpenSSL generated file
$privateKeyPath = ".\private.key" # Ensure this path is correct
$privateKeyContent = Get-Content -Path $privateKeyPath -Raw

$rsa = [System.Security.Cryptography.RSA]::Create()
$rsa.ImportFromPem($privateKeyContent)


# 1. Base64Url Encode Header and Payload
# Function to helper with Base64Url encoding (no padding, url safe)
function ConvertTo-Base64UrlString {
    param([byte[]]$Bytes)
    $base64 = [Convert]::ToBase64String($Bytes)
    return $base64.Replace('+','-').Replace('/','_').TrimEnd('=')
}

$headerBytes  = [System.Text.Encoding]::UTF8.GetBytes($header)
$payloadBytes = [System.Text.Encoding]::UTF8.GetBytes($payload)

$encodedHeader  = ConvertTo-Base64UrlString -Bytes $headerBytes
$encodedPayload = ConvertTo-Base64UrlString -Bytes $payloadBytes

# 2. Create the "Signing Input" (Header + . + Payload)
$signingInput = "$encodedHeader.$encodedPayload"
$signingInputBytes = [System.Text.Encoding]::UTF8.GetBytes($signingInput)

# 3. Sign the Input
$signatureBytes = $rsa.SignData(
    $signingInputBytes, 
    [System.Security.Cryptography.HashAlgorithmName]::SHA256,
     [System.Security.Cryptography.RSASignaturePadding]::Pss
     )
$encodedSignature = ConvertTo-Base64UrlString -Bytes $signatureBytes

# 4. Construct Detached JWS (Header + .. + Signature)
$detachedJws = "$encodedHeader..$encodedSignature"

Write-Host "--- DETACHED JWS ---" -ForegroundColor Cyan
Write-Host $detachedJws
Set-Content -Path ".\detachedJws.txt" -Value $detachedJws
Write-Host ""
Write-Host "--- PUBLIC KEY (To Verify) ---" -ForegroundColor Cyan

$publicKey=$rsa.ExportSubjectPublicKeyInfoPem()

Write-Host $publicKey
Set-Content -Path ".\public.pem" -Value $publicKey