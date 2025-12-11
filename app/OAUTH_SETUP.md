# OAuth 설정 가이드

이 문서는 텅장히어로 앱의 OAuth 로그인 기능 설정 방법을 안내합니다.

## 1. Google Sign-In 설정

### Android 설정

1. Firebase Console에서 프로젝트 생성
   - https://console.firebase.google.com/ 접속
   - 새 프로젝트 생성 또는 기존 프로젝트 선택

2. Android 앱 추가
   - Firebase 프로젝트 설정 > 앱 추가 > Android 선택
   - 패키지 이름 입력: `com.tungjang.hero` (또는 실제 패키지명)
   - SHA-1 인증서 지문 추가 (디버그 & 릴리즈)

   ```bash
   # 디버그 SHA-1 가져오기
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

3. `google-services.json` 다운로드
   - 다운로드한 파일을 `android/app/` 폴더에 복사

4. `android/build.gradle` 수정 (이미 설정되어 있을 수 있음)
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
   }
   ```

5. `android/app/build.gradle` 수정 (이미 설정되어 있을 수 있음)
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### iOS 설정

1. `GoogleService-Info.plist` 다운로드
   - Firebase Console > 프로젝트 설정 > iOS 앱 추가
   - 번들 ID 입력
   - `GoogleService-Info.plist` 다운로드

2. Xcode에서 파일 추가
   - Xcode에서 프로젝트 열기
   - `ios/Runner/` 폴더에 `GoogleService-Info.plist` 추가
   - "Copy items if needed" 체크

3. `ios/Runner/Info.plist` 수정
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <!-- REVERSED_CLIENT_ID 값을 GoogleService-Info.plist에서 복사 -->
               <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
           </array>
       </dict>
   </array>
   ```

## 2. Kakao Login 설정

### Kakao Developers Console 설정

1. Kakao Developers에 앱 등록
   - https://developers.kakao.com/ 접속
   - 내 애플리케이션 > 애플리케이션 추가하기
   - 앱 이름: "텅장히어로"

2. 플랫폼 설정
   - 앱 설정 > 플랫폼 > Android 플랫폼 등록
     - 패키지명: `com.tungjang.hero`
     - 키 해시 등록 (디버그 & 릴리즈)

   ```bash
   # Android 키 해시 생성
   keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64
   ```

   - iOS 플랫폼 등록
     - 번들 ID 입력

3. Kakao 로그인 활성화
   - 제품 설정 > Kakao 로그인
   - Kakao 로그인 활성화 ON
   - Redirect URI 설정: `kakaoYOUR_APP_KEY://oauth`

4. 동의항목 설정
   - 제품 설정 > Kakao 로그인 > 동의항목
   - 필수 동의: 닉네임, 프로필 이미지, 이메일

### Android 설정

1. `android/app/build.gradle` 수정
   ```gradle
   android {
       defaultConfig {
           manifestPlaceholders = [
               'KAKAO_APP_KEY': 'YOUR_KAKAO_NATIVE_APP_KEY'
           ]
       }
   }
   ```

2. `android/app/src/main/AndroidManifest.xml` 수정
   ```xml
   <manifest>
       <application>
           <!-- 기존 activity들 -->

           <!-- Kakao SDK -->
           <activity
               android:name="com.kakao.sdk.auth.AuthCodeHandlerActivity"
               android:exported="true">
               <intent-filter>
                   <action android:name="android.intent.action.VIEW" />
                   <category android:name="android.intent.category.DEFAULT" />
                   <category android:name="android.intent.category.BROWSABLE" />
                   <data
                       android:host="oauth"
                       android:scheme="kakao${KAKAO_APP_KEY}" />
               </intent-filter>
           </activity>
       </application>
   </manifest>
   ```

### iOS 설정

1. `ios/Runner/Info.plist` 수정
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>kakaoYOUR_KAKAO_APP_KEY</string>
           </array>
       </dict>
   </array>

   <key>LSApplicationQueriesSchemes</key>
   <array>
       <string>kakaokompassauth</string>
       <string>kakaolink</string>
   </array>

   <key>KAKAO_APP_KEY</key>
   <string>YOUR_KAKAO_NATIVE_APP_KEY</string>
   ```

## 3. 앱 코드 수정

### main.dart에서 Kakao 앱 키 설정

`lib/main.dart` 파일에서:

```dart
KakaoSdk.init(
  nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY',  // Kakao Developers에서 발급받은 네이티브 앱 키
  javaScriptAppKey: 'YOUR_KAKAO_JAVASCRIPT_APP_KEY',  // JavaScript 앱 키
);
```

## 4. 백엔드 API 엔드포인트

다음 API 엔드포인트가 백엔드에 구현되어 있어야 합니다:

### OAuth 로그인
- `POST /auth/google` - Google ID 토큰으로 로그인
  ```json
  {
    "id_token": "google_id_token"
  }
  ```

- `POST /auth/kakao` - Kakao Access 토큰으로 로그인
  ```json
  {
    "access_token": "kakao_access_token"
  }
  ```

### 계정 복구
- `POST /auth/find-email` - 닉네임으로 이메일 찾기
  ```json
  {
    "nickname": "user_nickname"
  }
  ```
  Response:
  ```json
  {
    "masked_email": "h***@gmail.com"
  }
  ```

- `POST /auth/password-reset` - 비밀번호 재설정 요청
  ```json
  {
    "email": "user@example.com"
  }
  ```

- `POST /auth/password-reset/confirm` - 비밀번호 재설정 확인
  ```json
  {
    "token": "reset_token_from_email",
    "new_password": "new_password"
  }
  ```

## 5. 테스트

1. 앱 실행
   ```bash
   flutter run
   ```

2. 로그인 화면에서 테스트
   - Google 로그인 버튼 클릭
   - Kakao 로그인 버튼 클릭
   - 아이디 찾기 링크 클릭
   - 비밀번호 찾기 링크 클릭

## 6. 주의사항

- 프로덕션 환경에서는 반드시 릴리즈 키 해시와 SHA-1을 등록해야 합니다.
- Kakao 앱 키와 Google 클라이언트 ID는 환경변수나 별도 설정 파일로 관리하는 것을 권장합니다.
- 딥 링크로 비밀번호 재설정 링크를 받으려면 앱의 딥 링크 설정이 필요합니다.

## 7. 문제 해결

### Google Sign-In 오류
- SHA-1 지문이 올바르게 등록되었는지 확인
- `google-services.json` 파일이 올바른 위치에 있는지 확인
- Firebase Console에서 Google 로그인 활성화 확인

### Kakao Login 오류
- 앱 키가 올바르게 설정되었는지 확인
- 키 해시가 올바르게 등록되었는지 확인
- Kakao Developers Console에서 플랫폼 설정 확인
- 패키지명/번들 ID가 일치하는지 확인

### 이메일로 링크가 오지 않는 경우
- 스팸 메일함 확인
- 백엔드 이메일 발송 설정 확인
- 이메일 주소가 올바른지 확인
