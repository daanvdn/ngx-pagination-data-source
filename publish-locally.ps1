echo "Initializing local npm registry (Verdaccio)"
.\start-verdaccio.ps1

$local_registry = "http://localhost:4873"
#get absolute path to .npmrc
$npmrc_path = (Resolve-Path .npmrc).Path
$env:NPM_CONFIG_USERCONFIG = $npmrc_path
echo "absolute path to .npmrc: $npmrc_path"
npm whoami  --registry=$local_registry --scope=@daanvdn
#fail if whoami was not successful
if ($LASTEXITCODE -ne 0) {
    Write-Host "npm login failed. Please check your credentials." -ForegroundColor Red
    exit 1
}
cd projects/ngx-pagination-data-source
npm install

# Add timestamp to package.json
$timestamp = [DateTime]::Now.ToString("o")


$packageJson = [PSCustomObject]@{
    name = "@daanvdn/ngx-pagination-data-source"
    version = "7.0.0"
    main = "index.js"
    types = "index.d.ts"
    files = @("**/*")
    publishConfig = @{
        "@daanvdn:registry" = $local_registry
    }
    generatedAt = $timestamp
}

# Preserve existing properties from the original package.json
$originalJson = Get-Content -Raw -Path projects/ngx-pagination-data-source/package.json -Encoding utf8 | ConvertFrom-Json
Write-Output "Original package.json properties: $($originalJson.PSObject.Properties.Name -join ', ')"
foreach ($property in $originalJson.PSObject.Properties) {
    if (-not $packageJson.PSObject.Properties[$property.Name]) {
        $packageJson | Add-Member -NotePropertyName $property.Name -NotePropertyValue $property.Value
    }
}

$packageJsonString = $packageJson | ConvertTo-Json -Compress -Depth 100
$packageJsonString = $packageJsonString -replace "\\u003e", ">" -replace "\\u003c", "<"

Write-Output "Updated package.json: $packageJsonString"

# Save updated package.json
$packageJsonString | Out-File -FilePath projects/ngx-pagination-data-source/package.json -Encoding utf8
npm pack

Write-Output "Publishing npm module to local registry"
npm publish --access public --registry=$local_registry
