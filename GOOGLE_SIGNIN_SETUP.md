# إعداد Google Sign-In لـ Android

## المشكلة الشائعة: ApiException: 10 (DEVELOPER_ERROR)

هذا الخطأ يحدث عادة بسبب عدم إضافة SHA-1 fingerprint في Firebase Console.

## خطوات الحل

### 1. الحصول على SHA-1 Fingerprint

#### الطريقة الأولى: استخدام سكريبت PowerShell (موصى بها)
```powershell
# من مجلد المشروع
cd Shark-Stage\android
.\get-sha1.ps1
```

أو من جذر المشروع:
```powershell
cd Shark-Stage
.\android\get-sha1.ps1
```

#### الطريقة الثانية: استخدام Flutter Gradle
```bash
# من جذر المشروع
cd android
gradlew signingReport

# أو على macOS/Linux
./gradlew signingReport
```

ابحث عن SHA-1 في المخرجات تحت "Variant: debug"

#### الطريقة الثالثة: استخدام keytool مباشرة

##### للـ Debug Keystore (للتطوير):
```bash
# على Windows (PowerShell)
cd $env:USERPROFILE\.android
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android

# على macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**ملاحظة**: إذا ظهرت رسالة "keytool is not recognized"، يجب إضافة Java إلى PATH أو استخدام الطريقة الأولى أو الثانية.

##### للـ Release Keystore (للإنتاج):
```bash
keytool -list -v -keystore path/to/your/release.keystore -alias your-key-alias
```

### 2. إضافة SHA-1 في Firebase Console

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروعك: `shark-stage-4e60d`
3. اذهب إلى **Project Settings** (⚙️) > **Your apps**
4. اختر تطبيق Android الخاص بك (`com.example.finial_project`)
5. انقر على **Add fingerprint**
6. الصق SHA-1 fingerprint الذي حصلت عليه من الخطوة السابقة
7. انقر **Save**

### 3. تحميل google-services.json المحدث

1. بعد إضافة SHA-1، قم بتحميل ملف `google-services.json` المحدث
2. استبدل الملف الموجود في `android/app/google-services.json`
3. أعد بناء التطبيق:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### 4. التحقق من التكوين

تأكد من:
- ✅ `google-services.json` موجود في `android/app/`
- ✅ `google-services` plugin مضاف في `android/app/build.gradle.kts`
- ✅ SHA-1 fingerprint مضاف في Firebase Console
- ✅ Package name في Firebase يطابق `com.example.finial_project`

## ملاحظات مهمة

- **للـ Debug**: استخدم SHA-1 من `debug.keystore`
- **للـ Release**: استخدم SHA-1 من `release.keystore` الخاص بك
- قد تحتاج إلى إضافة **SHA-256** أيضاً في بعض الحالات
- بعد إضافة SHA-1، قد يستغرق الأمر بضع دقائق حتى يتم التحديث

## استكشاف الأخطاء

### الخطأ: "keytool is not recognized"
- **السبب**: Java غير موجود في PATH
- **الحل**: 
  - استخدم السكريبت `get-sha1.ps1` (سيحاول العثور على keytool تلقائياً)
  - أو استخدم `gradlew signingReport` من مجلد android
  - أو أضف Java إلى PATH: `C:\Program Files\Java\jdk-XX\bin`

### الخطأ: "ApiException: 10"
- **السبب**: SHA-1 غير مضاف أو غير صحيح
- **الحل**: أضف SHA-1 في Firebase Console

### الخطأ: "sign_in_failed"
- **السبب**: مشكلة في تكوين OAuth client
- **الحل**: تحقق من `GOOGLE_CLIENT_ID` في الكود يطابق Client ID في Firebase

### الخطأ: "Unable to retrieve serverAuthCode"
- **السبب**: `serverClientId` غير صحيح أو غير مطابق للخادم
- **الحل**: تأكد من تطابق `GOOGLE_SERVER_CLIENT_ID` في Flutter مع `GOOGLE_CLIENT_ID` في الخادم

## روابط مفيدة

- [Firebase Console](https://console.firebase.google.com/)
- [Google Sign-In Documentation](https://pub.dev/packages/google_sign_in)
- [Flutter Firebase Setup](https://firebase.flutter.dev/docs/overview)

