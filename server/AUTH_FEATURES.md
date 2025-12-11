# Authentication Features Documentation

This document describes the authentication features implemented in the 텅장히어로 (Tungjang Hero) backend.

## Features Implemented

### 1. OAuth2 Google Authentication
### 2. OAuth2 Kakao Authentication
### 3. Find Email (아이디 찾기)
### 4. Password Reset

---

## Setup

### Environment Variables

Add these to your `.env` file:

```env
# OAuth Configuration
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
KAKAO_CLIENT_ID=your-kakao-rest-api-key
```

### Dependencies

The following package has been added to `go.mod`:
```
google.golang.org/api v0.162.0
```

Run `go mod tidy` to install all dependencies.

### Database Migration

The User model has been updated with new fields:
- `oauth_provider` (string) - OAuth provider name (google, kakao)
- `oauth_id` (string) - OAuth user ID from provider
- `password_reset_token` (string) - Token for password reset
- `password_reset_expiry` (timestamp) - Expiry time for reset token

Run the application to auto-migrate the database:
```bash
go run main.go
```

---

## API Endpoints

### 1. Google OAuth Login/Register

**POST** `/api/v1/auth/google`

Authenticates user with Google OAuth token. Creates new account if user doesn't exist.

**Request Body:**
```json
{
  "token": "google-id-token-from-mobile-app"
}
```

**Response (200 OK):**
```json
{
  "token": "jwt-token",
  "user": {
    "id": 1,
    "email": "user@gmail.com",
    "nickname": "User Name",
    "oauth_provider": "google",
    "created_at": "2025-12-11T...",
    "updated_at": "2025-12-11T...",
    "last_login_at": "2025-12-11T..."
  }
}
```

**How it works:**
1. Mobile app obtains Google ID token using Google Sign-In SDK
2. Mobile app sends token to this endpoint
3. Backend verifies token with Google's API
4. If user exists with this Google ID, logs them in
5. If user doesn't exist, creates new account
6. Returns JWT token for subsequent API calls

**Example (Flutter/Dart):**
```dart
// 1. Get Google ID token
final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
final String? idToken = googleAuth.idToken;

// 2. Send to backend
final response = await http.post(
  Uri.parse('https://your-api.com/api/v1/auth/google'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({'token': idToken}),
);
```

---

### 2. Kakao OAuth Login/Register

**POST** `/api/v1/auth/kakao`

Authenticates user with Kakao OAuth token. Creates new account if user doesn't exist.

**Request Body:**
```json
{
  "token": "kakao-access-token-from-mobile-app"
}
```

**Response (200 OK):**
```json
{
  "token": "jwt-token",
  "user": {
    "id": 2,
    "email": "user@kakao.com",
    "nickname": "카카오유저",
    "oauth_provider": "kakao",
    "created_at": "2025-12-11T...",
    "updated_at": "2025-12-11T...",
    "last_login_at": "2025-12-11T..."
  }
}
```

**How it works:**
1. Mobile app obtains Kakao access token using Kakao SDK
2. Mobile app sends token to this endpoint
3. Backend verifies token with Kakao's API
4. If user exists with this Kakao ID, logs them in
5. If user doesn't exist, creates new account
6. Returns JWT token for subsequent API calls

**Example (Flutter/Dart):**
```dart
// 1. Get Kakao access token
final token = await UserApi.instance.loginWithKakaoTalk();
final String accessToken = token.accessToken;

// 2. Send to backend
final response = await http.post(
  Uri.parse('https://your-api.com/api/v1/auth/kakao'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({'token': accessToken}),
);
```

**Note:** If user doesn't provide email permission, a synthetic email will be created: `kakao_<user_id>@tungjang-hero.local`

---

### 3. Find Email (아이디 찾기)

**POST** `/api/v1/auth/find-email`

Finds user's email by nickname and returns masked email for privacy.

**Request Body:**
```json
{
  "nickname": "홍길동"
}
```

**Response (200 OK):**
```json
{
  "email": "h***@gmail.com"
}
```

**Response (404 Not Found):**
```json
{
  "error": "User not found with this nickname"
}
```

**Email Masking Format:**
- Shows first character of local part
- Masks the rest with ***
- Shows full domain
- Example: `hello@example.com` → `h***@example.com`

---

### 4. Password Reset Request

**POST** `/api/v1/auth/password/reset-request`

Generates a password reset token for the user. In production, this token would be sent via email. For now, it's returned in the response for testing.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200 OK):**
```json
{
  "message": "Password reset token generated successfully",
  "token": "64-character-hex-token"
}
```

**Important Notes:**
- Token expires after 1 hour
- Only works for non-OAuth accounts (users who registered with email/password)
- For security, always returns 200 OK even if email doesn't exist
- OAuth users cannot reset password (they must use their OAuth provider)

**Error Response (400 Bad Request) - OAuth User:**
```json
{
  "error": "Cannot reset password for OAuth accounts"
}
```

---

### 5. Password Reset Confirm

**POST** `/api/v1/auth/password/reset-confirm`

Verifies the reset token and sets a new password.

**Request Body:**
```json
{
  "token": "64-character-hex-token-from-reset-request",
  "new_password": "newSecurePassword123"
}
```

**Response (200 OK):**
```json
{
  "message": "Password reset successfully"
}
```

**Error Responses:**

**400 Bad Request - Invalid/Expired Token:**
```json
{
  "error": "Invalid or expired reset token"
}
```

**400 Bad Request - Token Expired:**
```json
{
  "error": "Reset token has expired"
}
```

---

## Complete User Flow Examples

### Google OAuth Registration & Login Flow

```
1. User clicks "Sign in with Google" in mobile app
2. Mobile app opens Google Sign-In
3. User authenticates with Google
4. Mobile app receives Google ID token
5. Mobile app sends token to: POST /api/v1/auth/google
6. Backend verifies token with Google
7. Backend checks if user exists:
   - If exists: Log in user
   - If not exists: Create new user with Google info
8. Backend returns JWT token
9. Mobile app stores JWT token
10. Mobile app uses JWT for all subsequent API calls
```

### Password Reset Flow

```
1. User clicks "Forgot Password?"
2. User enters email
3. App sends: POST /api/v1/auth/password/reset-request
4. Backend generates reset token (expires in 1 hour)
5. Backend returns token (in production, would send via email)
6. User enters token and new password
7. App sends: POST /api/v1/auth/password/reset-confirm
8. Backend verifies token and updates password
9. User can now login with new password
```

### Find Email Flow

```
1. User clicks "Find My Email"
2. User enters nickname
3. App sends: POST /api/v1/auth/find-email
4. Backend finds user by nickname
5. Backend masks email: "hello@example.com" → "h***@example.com"
6. Backend returns masked email
7. User can now attempt to login with this email
```

---

## Data Model Changes

### User Model Updates

```go
type User struct {
    ID           uint
    Email        string
    Password     string    // Now optional (not required for OAuth users)
    Nickname     string
    CreatedAt    time.Time
    UpdatedAt    time.Time
    LastLoginAt  *time.Time

    // OAuth fields (NEW)
    OAuthProvider string     // "google", "kakao", or empty for regular users
    OAuthID       string     // OAuth user ID from provider

    // Password reset fields (NEW)
    PasswordResetToken  string     // Secure random token
    PasswordResetExpiry *time.Time // Token expiration timestamp

    // Relations
    Hero         *Hero
    Transactions []Transaction
}
```

---

## Security Considerations

### OAuth Token Verification

1. **Google**: Uses `google.golang.org/api/idtoken` package to verify tokens
   - Validates token signature
   - Checks token audience (client ID)
   - Verifies token hasn't expired
   - Ensures email is verified

2. **Kakao**: Makes direct API call to Kakao's `/v2/user/me` endpoint
   - Validates access token with Kakao servers
   - Gets user profile information
   - Handles cases where email permission not granted

### Password Reset Security

1. **Token Generation**: Uses `crypto/rand` for cryptographically secure random tokens (256-bit)
2. **Token Expiry**: Tokens expire after 1 hour
3. **One-Time Use**: Token is deleted after successful password reset
4. **Email Enumeration Prevention**: Always returns success even if email doesn't exist
5. **OAuth Protection**: Prevents password reset for OAuth users

### Email Masking

- Prevents email harvesting
- Shows just enough information for user to recognize their email
- Format: `<first_char>***@domain.com`

---

## Testing

### Test with cURL

**Google OAuth:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/google \
  -H "Content-Type: application/json" \
  -d '{"token": "your-google-id-token"}'
```

**Kakao OAuth:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/kakao \
  -H "Content-Type: application/json" \
  -d '{"token": "your-kakao-access-token"}'
```

**Find Email:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/find-email \
  -H "Content-Type: application/json" \
  -d '{"nickname": "TestUser"}'
```

**Password Reset Request:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/password/reset-request \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com"}'
```

**Password Reset Confirm:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/password/reset-confirm \
  -H "Content-Type: application/json" \
  -d '{
    "token": "64-char-token-from-reset-request",
    "new_password": "newPassword123"
  }'
```

---

## Next Steps

### Production Considerations

1. **Email Service Integration**
   - Remove `token` field from password reset response
   - Integrate email service (SendGrid, AWS SES, etc.)
   - Send password reset link via email
   - Create email templates

2. **OAuth Client IDs**
   - Configure Google OAuth in Google Cloud Console
   - Configure Kakao OAuth in Kakao Developers Console
   - Add client IDs to production environment variables

3. **Rate Limiting**
   - Add rate limiting to password reset endpoints
   - Implement CAPTCHA for sensitive operations
   - Monitor for abuse patterns

4. **Monitoring & Logging**
   - Log OAuth authentication attempts
   - Monitor failed login attempts
   - Alert on suspicious password reset activity

---

## Troubleshooting

### Google OAuth Issues

**Error: "Invalid Google token"**
- Ensure Google Client ID matches the one in `.env`
- Verify token is an ID token, not access token
- Check token hasn't expired (tokens expire quickly)
- Ensure mobile app uses correct Google Client ID

### Kakao OAuth Issues

**Error: "Invalid Kakao token"**
- Verify token is a valid Kakao access token
- Check token hasn't expired
- Ensure Kakao app is properly configured
- Verify REST API key is correct

### Password Reset Issues

**Error: "Cannot reset password for OAuth accounts"**
- User registered via Google/Kakao OAuth
- They must use OAuth provider to login
- Consider adding account linking feature

**Token Expired**
- Reset tokens expire after 1 hour
- User must request new reset token
- Consider adding token refresh endpoint

---

## File Structure

```
server/
├── internal/
│   ├── config/
│   │   └── config.go              # Added OAuth config
│   ├── domain/
│   │   └── models/
│   │       └── user.go            # Updated with OAuth & reset fields
│   ├── handlers/
│   │   └── auth.go                # Added 5 new handlers
│   ├── services/
│   │   ├── oauth.go               # NEW: OAuth verification
│   │   └── utils.go               # NEW: Helper functions
│   └── middleware/
│       └── auth.go
├── main.go                         # Added new routes
├── .env.example                    # Added OAuth variables
└── AUTH_FEATURES.md               # This file
```

---

## Support

For issues or questions:
1. Check error messages in response
2. Review server logs for detailed errors
3. Ensure all environment variables are set
4. Verify database migrations completed successfully
