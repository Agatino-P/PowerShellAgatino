# 1. INPUT DATA
# -----------------------------------------------------------
# The Detached JWS (Header..Signature)
$detachedJws = Get-Content -Path ".\detachedJws.txt"

# 2. HELPER FUNCTIONS
# -----------------------------------------------------------
# Helper to encode to Base64Url (needed to reconstruct the signing input)
function ConvertTo-Base64UrlString {
    param([byte[]]$Bytes)
    $base64 = [Convert]::ToBase64String($Bytes)
    return $base64.Replace('+', '-').Replace('/', '_').TrimEnd('=')
}

# Helper to decode from Base64Url (needed to get raw signature bytes)
function ConvertFrom-Base64UrlString {
    param([string]$InputString)
    $base64 = $InputString.Replace('-', '+').Replace('_', '/')
    switch ($base64.Length % 4) {
        2 { $base64 += "==" }
        3 { $base64 += "=" }
    }
    return [Convert]::FromBase64String($base64)
}

# 3. PREPARE VERIFICATION DATA
# -----------------------------------------------------------
try {

    $detachedJws = Get-Content -Path ".\detachedJws.txt"

    # Split the JWS to get Header and Signature
    $parts = $detachedJws.Split('.')
    
    $encodedHeader = $parts[0]
    $decodedHeaderBytes = ConvertFrom-Base64UrlString($encodedHeader)

    $headerJsonString = [System.Text.Encoding]::UTF8.GetString($decodedHeaderBytes)

    # 2. Convert the JSON string to a PowerShell object
    $headerData = $headerJsonString | ConvertFrom-Json
    $iat = $headerData.'http://fm.bottomline.com/iat'

    $encodedSignature = $parts[2] # Note: part[1] is empty in detached JWS

    # We must Base64Url Encode the payload to match the original signing input
    $payloadBytes = [System.Text.Encoding]::UTF8.GetBytes($originalPayload)
    $encodedPayload = ConvertTo-Base64UrlString -Bytes $payloadBytes

    # Reconstruct the data that was actually signed: "Header.Payload"
    $contentToVerify = "$encodedHeader.$encodedPayload"
    $contentToVerifyBytes = [System.Text.Encoding]::UTF8.GetBytes($contentToVerify)

    # Decode the signature string back to bytes
    $signatureBytes = ConvertFrom-Base64UrlString -InputString $encodedSignature

    # 4. PERFORM VERIFICATION
    # -----------------------------------------------------------
    $rsa = [System.Security.Cryptography.RSA]::Create()
    $rsa.ImportFromPem($publicKeyPem)

    # Verify using SHA256 and PKCS1 padding (Standard for RS256)
    $isValid = $rsa.VerifyData(
        $contentToVerifyBytes,
        $signatureBytes,
        [System.Security.Cryptography.HashAlgorithmName]::SHA256,
        [System.Security.Cryptography.RSASignaturePadding]::Pss
    )

    Write-Host "--------------------------------"
    if ($isValid) {
        Write-Host "SUCCESS: Signature is VALID." -ForegroundColor Green
    }
    else {
        Write-Host "FAILURE: Signature is INVALID." -ForegroundColor Red
    }
    Write-Host "--------------------------------"

}
catch {
    Write-Error $_
}