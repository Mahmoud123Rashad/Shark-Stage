#!/bin/bash
# Bash script to get SHA-1 fingerprint for Android
# Run this script from the android directory

echo "========================================="
echo "Getting SHA-1 Fingerprint for Android"
echo "========================================="
echo ""

DEBUG_KEYSTORE="$HOME/.android/debug.keystore"

if [ -f "$DEBUG_KEYSTORE" ]; then
    echo "Found debug keystore at: $DEBUG_KEYSTORE"
    echo ""
    echo "SHA-1 Fingerprint:"
    echo "------------------"
    keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android | grep "SHA1:"
    
    echo ""
    echo "SHA-256 Fingerprint:"
    echo "-------------------"
    keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android | grep "SHA256:"
    
    echo ""
    echo "========================================="
    echo "Next Steps:"
    echo "1. Copy the SHA-1 fingerprint above"
    echo "2. Go to Firebase Console > Project Settings > Your apps"
    echo "3. Select your Android app"
    echo "4. Click 'Add fingerprint' and paste the SHA-1"
    echo "5. Download the updated google-services.json"
    echo "6. Replace android/app/google-services.json"
    echo "7. Run: flutter clean && flutter run"
    echo "========================================="
else
    echo "Error: Debug keystore not found at: $DEBUG_KEYSTORE"
    echo ""
    echo "The debug keystore will be created automatically when you build the app."
    echo "Please build the app first, then run this script again."
fi

