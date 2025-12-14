# Firebase Google Sign-In Setup Guide

## Lỗi hiện tại: ApiException: 10 (DEVELOPER_ERROR)

Lỗi này xảy ra vì SHA-1 fingerprint chưa được thêm vào Firebase Console.

## Giải pháp:

### Bước 1: Lấy SHA-1 Fingerprint

**Debug Keystore (đã có):**
```
SHA1: E0:FD:B6:0A:4D:24:00:AE:36:F3:01:5E:F5:47:15:D1:92:79:B5:9D
SHA256: B5:EE:90:DB:74:04:AA:5B:A9:45:07:EF:0D:CB:05:FA:B7:48:04:54:41:A8:62:63:B9:DD:2C:C5:CB:8E:5D:EC
```

**Để lấy SHA-1 cho Release keystore (nếu có):**
```bash
keytool -list -v -keystore /path/to/your-release.keystore -alias your-key-alias
```

### Bước 2: Thêm SHA-1 vào Firebase Console

1. Đăng nhập vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project: **smarthome-41aff**
3. Vào **Project Settings** (⚙️) → **Your apps**
4. Chọn app Android: **com.example.smarthome_app**
5. Trong phần **SHA certificate fingerprints**, click **Add fingerprint**
6. Thêm SHA-1: `E0:FD:B6:0A:4D:24:00:AE:36:F3:01:5E:F5:47:15:D1:92:79:B5:9D`
7. Click **Save**

### Bước 3: Kiểm tra Google Sign-In đã được bật

1. Vào **Authentication** → **Sign-in method**
2. Đảm bảo **Google** đã được **Enable**
3. Nếu chưa, click **Google** → **Enable** → **Save**

### Bước 4: Tải lại google-services.json (nếu cần)

Sau khi thêm SHA-1, có thể cần tải lại `google-services.json`:
1. Vào **Project Settings** → **Your apps**
2. Chọn app Android
3. Click **Download google-services.json**
4. Thay thế file hiện tại tại: `android/app/google-services.json`

### Bước 5: Rebuild và test

```bash
flutter clean
flutter pub get
flutter run
```

## Package Name hiện tại:
- **com.example.smarthome_app** (đã đổi từ com.example.smart_home_app)

## OAuth Client ID từ google-services.json:
- **81741509116-gm22sflk4qqs00jbehmca799j09e23rq.apps.googleusercontent.com**

## Lưu ý:
- SHA-1 fingerprint **PHẢI** được thêm vào Firebase Console
- Có thể mất vài phút để Firebase cập nhật sau khi thêm SHA-1
- Nếu vẫn lỗi, kiểm tra lại package name trong Firebase Console phải khớp với `build.gradle`

