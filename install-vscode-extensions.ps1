# VSCode Extension Installer for Neovim Integration
# This script installs recommended VSCode extensions for Neovim compatibility

Write-Host "Installing VSCode Extensions for Neovim Integration..." -ForegroundColor Green
Write-Host ""

# Required Extensions
Write-Host "Installing REQUIRED extensions..." -ForegroundColor Yellow

$requiredExtensions = @(
    "asvetliakov.vscode-neovim"  # VSCode Neovim
)

foreach ($ext in $requiredExtensions)
{
    Write-Host "Installing: $ext"
    code --install-extension $ext --force
}

Write-Host ""
Write-Host "Installing RECOMMENDED extensions..." -ForegroundColor Yellow

# Recommended Extensions
# Get extensions from extensions.json
$extensionsFile = "extensions.json"
if (Test-Path $extensionsFile)
{
    # Get all the extension IDs from the JSON file under the identifier.id key
    $recommendedExtensions = Get-Content $extensionsFile | ConvertFrom-Json | ForEach-Object { $_.identifier.id }
} else
{
    Write-Host "Warning: $extensionsFile not found. No recommended extensions will be installed." -ForegroundColor Red
    $recommendedExtensions = @()
}

foreach ($ext in $recommendedExtensions)
{
    Write-Host "Installing: $ext"
    code --install-extension $ext --force
}

Write-Host ""
Write-Host "✅ Extension installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Copy settings from vscode-settings.json to your VSCode settings" -ForegroundColor White
Write-Host "   (Ctrl+, → Open Settings (JSON) icon in top right)" -ForegroundColor White
Write-Host "2. Copy contents of vscode-keybindings.json to your VSCode keybindings" -ForegroundColor White
Write-Host "   (Ctrl+Shift+P → 'Preferences: Open Keyboard Shortcuts (JSON)')" -ForegroundColor White
Write-Host "3. Reload VSCode window (Ctrl+Shift+P → 'Developer: Reload Window')" -ForegroundColor White
Write-Host ""
Write-Host "See INSTALLATION_CHECKLIST.md for detailed instructions!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
