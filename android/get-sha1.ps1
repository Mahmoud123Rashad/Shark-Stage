# PowerShell script to get SHA-1 fingerprint for Android
# Run this script from the android directory or project root

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Getting SHA-1 Fingerprint for Android" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Function to find keytool
function Find-Keytool {
    $keytoolPaths = @(
        "$env:JAVA_HOME\bin\keytool.exe",
        "$env:ProgramFiles\Java\*\bin\keytool.exe",
        "$env:ProgramFiles(x86)\Java\*\bin\keytool.exe",
        "$env:LOCALAPPDATA\Android\Sdk\jbr\bin\keytool.exe",
        "$env:LOCALAPPDATA\Android\Sdk\jre\bin\keytool.exe"
    )
    
    # Check if keytool is in PATH
    $keytool = Get-Command keytool -ErrorAction SilentlyContinue
    if ($keytool) {
        return $keytool.Path
    }
    
    # Search common Java locations
    foreach ($path in $keytoolPaths) {
        $resolved = Resolve-Path $path -ErrorAction SilentlyContinue
        if ($resolved) {
            return $resolved[0].Path
        }
    }
    
    return $null
}

# Try to use Flutter gradle first (easier method)
Write-Host "Method 1: Using Flutter Gradle (Recommended)" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Yellow
Write-Host ""

# Check if we're in android directory or project root
$currentDir = $PWD.Path
$gradlewPath = Join-Path $currentDir "gradlew.bat"

# If not found, try parent/android
if (-not (Test-Path $gradlewPath)) {
    $parentDir = Split-Path -Parent $currentDir
    $gradlewPath = Join-Path $parentDir "android\gradlew.bat"
}

# If still not found, try from script location
if (-not (Test-Path $gradlewPath) -and $PSScriptRoot) {
    $gradlewPath = Join-Path $PSScriptRoot "gradlew.bat"
}

if (Test-Path $gradlewPath) {
    $androidDir = Split-Path -Parent $gradlewPath
    Write-Host "Running: gradlew signingReport..." -ForegroundColor Green
    Write-Host ""
    
    Push-Location $androidDir
    try {
        # Capture both stdout and stderr using cmd
        $output = cmd.exe /c ".\gradlew.bat signingReport 2>&1" | Out-String
        
        # Extract SHA-1 from output
        $sha1Matches = $output | Select-String -Pattern "SHA1:\s*([A-F0-9:]+)" -AllMatches
        if ($sha1Matches -and $sha1Matches.Matches.Count -gt 0) {
            Write-Host "SHA-1 Fingerprint(s) found:" -ForegroundColor Green
            $uniqueSha1 = @()
            foreach ($match in $sha1Matches.Matches) {
                $sha1 = $match.Groups[1].Value.Trim()
                if ($sha1 -and $uniqueSha1 -notcontains $sha1) {
                    $uniqueSha1 += $sha1
                    Write-Host "  $sha1" -ForegroundColor White
                }
            }
            Write-Host ""
            Write-Host "Copy the SHA-1 above and add it to Firebase Console" -ForegroundColor Cyan
            Write-Host ""
        } else {
            Write-Host "Could not extract SHA-1 from gradle output." -ForegroundColor Yellow
            Write-Host "Trying alternative method..." -ForegroundColor Yellow
            Write-Host ""
        }
    } catch {
        Write-Host "Error running gradlew: $_" -ForegroundColor Red
        Write-Host "Trying alternative method..." -ForegroundColor Yellow
        Write-Host ""
    } finally {
        Pop-Location
    }
}

# Alternative: Use keytool directly
Write-Host "Method 2: Using keytool directly" -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Yellow
Write-Host ""

$keytoolPath = Find-Keytool
$debugKeystore = "$env:USERPROFILE\.android\debug.keystore"

if (-not $keytoolPath) {
    Write-Host "keytool not found in PATH or common Java locations." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please try one of these solutions:" -ForegroundColor Yellow
    Write-Host "1. Add Java to PATH:" -ForegroundColor White
    Write-Host "   - Find your Java installation (usually in Program Files\Java)" -ForegroundColor Gray
    Write-Host "   - Add the 'bin' folder to your PATH environment variable" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Use Flutter method (already tried above)" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Manual command (replace JAVA_PATH with your Java path):" -ForegroundColor White
    Write-Host "   JAVA_PATH\bin\keytool -list -v -keystore $debugKeystore -alias androiddebugkey -storepass android -keypass android" -ForegroundColor Gray
    Write-Host ""
} elseif (Test-Path $debugKeystore) {
    Write-Host "Found keytool at: $keytoolPath" -ForegroundColor Green
    Write-Host "Found debug keystore at: $debugKeystore" -ForegroundColor Green
    Write-Host ""
    Write-Host "SHA-1 Fingerprint:" -ForegroundColor Yellow
    Write-Host "------------------" -ForegroundColor Yellow
    
    & $keytoolPath -list -v -keystore $debugKeystore -alias androiddebugkey -storepass android -keypass android | Select-String -Pattern "SHA1:"
    
    Write-Host ""
    Write-Host "SHA-256 Fingerprint:" -ForegroundColor Yellow
    Write-Host "-------------------" -ForegroundColor Yellow
    
    & $keytoolPath -list -v -keystore $debugKeystore -alias androiddebugkey -storepass android -keypass android | Select-String -Pattern "SHA256:"
} else {
    Write-Host "Debug keystore not found at: $debugKeystore" -ForegroundColor Red
    Write-Host ""
    Write-Host "The debug keystore will be created automatically when you build the app." -ForegroundColor Yellow
    Write-Host "Please build the app first, then run this script again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or run: flutter build apk --debug" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Copy the SHA-1 fingerprint above" -ForegroundColor White
Write-Host "2. Go to Firebase Console -> Project Settings -> Your apps" -ForegroundColor White
Write-Host "   https://console.firebase.google.com/" -ForegroundColor Gray
Write-Host "3. Select your Android app (com.example.finial_project)" -ForegroundColor White
Write-Host "4. Click 'Add fingerprint' and paste the SHA-1" -ForegroundColor White
Write-Host "5. Download the updated google-services.json" -ForegroundColor White
Write-Host "6. Replace android/app/google-services.json" -ForegroundColor White
Write-Host "7. Run: flutter clean; flutter run" -ForegroundColor White
Write-Host "   (or: flutter clean and then flutter run)" -ForegroundColor Gray
Write-Host "=========================================" -ForegroundColor Cyan
