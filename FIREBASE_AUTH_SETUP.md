# Firebase Authentication Setup - Hướng Dẫn

## ✅ Đã Hoàn Thành

### 1. **Cấu Hình Firebase**
- ✅ File `google-services.json` đã đặt đúng vị trí: `android/app/google-services.json`
- ✅ Thêm Firebase dependencies vào `pubspec.yaml`
- ✅ Cấu hình Android `build.gradle` với Google Services plugin
- ✅ Khởi tạo Firebase trong `main.dart`

### 2. **Clean Architecture cho Auth**
- ✅ **Domain Layer**: Entities, Repository interface, Use Cases
- ✅ **Data Layer**: Firebase Data Sources, Repository implementation
- ✅ **Dependency Injection**: Riverpod providers cho DI
- ✅ **Presentation**: AuthController và UI screens

### 3. **Phone Authentication**
- ✅ Gửi OTP qua Firebase
- ✅ Xác thực OTP code
- ✅ Tự động format số điện thoại (E.164: +84...)
- ✅ Xử lý auto-verification

### 4. **Google Sign-In**
- ✅ Tích hợp Google Sign-In
- ✅ Kết nối với Firebase Authentication
- ✅ Lấy user profile (name, email, photo)

## 📁 Cấu Trúc Files

```
lib/features/auth/
├── domain/
│   ├── entities/
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── sign_in_with_phone_use_case.dart
│       ├── verify_otp_use_case.dart
│       ├── sign_in_with_google_use_case.dart
│       ├── get_current_user_use_case.dart
│       └── sign_out_use_case.dart
├── data/
│   ├── datasources/
│   │   ├── auth_firebase_datasource.dart
│   │   └── auth_google_datasource.dart
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── di/
│   └── auth_dependencies.dart
├── providers/
│   ├── auth_controller.dart (NEW)
│   └── auth_session_provider.dart (Updated)
└── presentation/
    ├── login_screen.dart (Updated - Google Sign-In)
    ├── login_phone_screen.dart (Updated - Phone Auth)
    └── security_pin_screen.dart (Updated - OTP Verification)
```

## 🚀 Cách Sử Dụng

### Phone Authentication Flow

1. **Nhập số điện thoại** (LoginPhoneScreen)
   - User nhập số điện thoại
   - App tự động format thành +84...
   - Gửi OTP qua Firebase

2. **Xác thực OTP** (SecurityPinScreen)
   - User nhập 6 số OTP
   - Verify với Firebase
   - Tự động navigate đến dashboard khi thành công

### Google Sign-In Flow

1. **Chọn Google Sign-In** (LoginScreen)
   - User click "Tiếp tục với Google"
   - Mở Google Sign-In dialog
   - Tự động navigate đến dashboard khi thành công

## 🔧 Firebase Console Setup

### Phone Authentication
1. Vào Firebase Console > Authentication
2. Enable **Phone** authentication
3. Thêm SHA-1 fingerprint (cho production)
4. Test với số điện thoại thật

### Google Sign-In
1. Vào Firebase Console > Authentication
2. Enable **Google** authentication
3. Thêm OAuth client ID (đã có trong google-services.json)
4. Cấu hình OAuth consent screen (nếu cần)

## ⚠️ Lưu Ý

1. **Phone Authentication**
   - Chỉ hoạt động với số điện thoại thật
   - Cần có internet connection
   - OTP code có thời hạn (60 giây)

2. **Google Sign-In**
   - Cần cấu hình OAuth client trong Firebase
   - Test trên device/emulator với Google Play Services

3. **Auto-Verification**
   - Một số device có thể auto-verify OTP
   - Code đã xử lý case này

## 📝 Next Steps

- [ ] Thêm error handling tốt hơn
- [ ] Thêm loading states
- [ ] Thêm retry mechanism cho OTP
- [ ] Lưu user info vào local storage
- [ ] Thêm logout functionality
- [ ] Test trên real device

---

**Ngày hoàn thành:** $(date)

