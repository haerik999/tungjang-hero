# Quick Start Guide - Testing New Auth Features

## Step 1: Install Dependencies

```bash
cd /home/fheldtm/development/project/flutters/텅장히어로/server
go mod tidy
```

## Step 2: Configure Environment (Optional for testing)

The app will work without OAuth credentials for testing other features. For OAuth testing, update `.env`:

```bash
cp .env.example .env
# Edit .env and add your OAuth credentials if testing OAuth
```

## Step 3: Run the Server

```bash
go run main.go
```

The server will automatically migrate the database with new User fields.

## Step 4: Test the Features

### Test 1: Find Email (아이디 찾기)

First, create a test user:
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "password123",
    "nickname": "테스트유저"
  }'
```

Now find the email by nickname:
```bash
curl -X POST http://localhost:8080/api/v1/auth/find-email \
  -H "Content-Type: application/json" \
  -d '{"nickname": "테스트유저"}'
```

**Expected Response:**
```json
{
  "email": "t***@example.com"
}
```

### Test 2: Password Reset Flow

Request a password reset token:
```bash
curl -X POST http://localhost:8080/api/v1/auth/password/reset-request \
  -H "Content-Type: application/json" \
  -d '{"email": "testuser@example.com"}'
```

**Expected Response:**
```json
{
  "message": "Password reset token generated successfully",
  "token": "a1b2c3d4e5f6...64-character-hex-token"
}
```

Copy the token and use it to reset password:
```bash
curl -X POST http://localhost:8080/api/v1/auth/password/reset-confirm \
  -H "Content-Type: application/json" \
  -d '{
    "token": "paste-token-here",
    "new_password": "newpassword123"
  }'
```

**Expected Response:**
```json
{
  "message": "Password reset successfully"
}
```

Now login with new password:
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "newpassword123"
  }'
```

### Test 3: Google OAuth (Requires Google Token)

You need a valid Google ID token from your mobile app. Example:
```bash
curl -X POST http://localhost:8080/api/v1/auth/google \
  -H "Content-Type: application/json" \
  -d '{"token": "your-google-id-token-here"}'
```

**Expected Response:**
```json
{
  "token": "jwt-token...",
  "user": {
    "id": 2,
    "email": "user@gmail.com",
    "nickname": "User Name",
    "oauth_provider": "google",
    "created_at": "...",
    "updated_at": "...",
    "last_login_at": "..."
  }
}
```

### Test 4: Kakao OAuth (Requires Kakao Token)

You need a valid Kakao access token from your mobile app. Example:
```bash
curl -X POST http://localhost:8080/api/v1/auth/kakao \
  -H "Content-Type: application/json" \
  -d '{"token": "your-kakao-access-token-here"}'
```

**Expected Response:**
```json
{
  "token": "jwt-token...",
  "user": {
    "id": 3,
    "email": "user@kakao.com",
    "nickname": "카카오유저",
    "oauth_provider": "kakao",
    "created_at": "...",
    "updated_at": "...",
    "last_login_at": "..."
  }
}
```

## Test 5: Error Cases

### Try to reset password for OAuth user
```bash
# First create OAuth user (or use existing one)
# Then try to reset password
curl -X POST http://localhost:8080/api/v1/auth/password/reset-request \
  -H "Content-Type: application/json" \
  -d '{"email": "user@gmail.com"}'
```

**Expected Response:**
```json
{
  "error": "Cannot reset password for OAuth accounts"
}
```

### Try to find email with non-existent nickname
```bash
curl -X POST http://localhost:8080/api/v1/auth/find-email \
  -H "Content-Type: application/json" \
  -d '{"nickname": "NonExistentUser"}'
```

**Expected Response:**
```json
{
  "error": "User not found with this nickname"
}
```

### Try to use expired reset token
Wait 1 hour after generating a reset token, then try to use it:
```bash
curl -X POST http://localhost:8080/api/v1/auth/password/reset-confirm \
  -H "Content-Type: application/json" \
  -d '{
    "token": "expired-token",
    "new_password": "newpassword123"
  }'
```

**Expected Response:**
```json
{
  "error": "Reset token has expired"
}
```

## All Endpoints Summary

```
POST /api/v1/auth/register           # Original - Register with email/password
POST /api/v1/auth/login              # Original - Login with email/password
POST /api/v1/auth/google             # NEW - OAuth login with Google
POST /api/v1/auth/kakao              # NEW - OAuth login with Kakao
POST /api/v1/auth/find-email         # NEW - Find email by nickname
POST /api/v1/auth/password/reset-request   # NEW - Request password reset
POST /api/v1/auth/password/reset-confirm   # NEW - Confirm password reset
POST /api/v1/auth/refresh            # Original - Refresh JWT token (protected)
```

## Troubleshooting

### Error: "go: command not found"
Go is not installed. The dependencies are already added to go.mod, so you can still review the code. To run it, install Go 1.21 or later.

### Error: "Failed to connect to database"
Make sure PostgreSQL is running and .env has correct database credentials.

### Error: "Invalid Google token"
- Ensure GOOGLE_CLIENT_ID in .env matches your Google app
- Token must be an ID token, not access token
- Token might have expired (they expire quickly)

### Error: "Invalid Kakao token"
- Token must be a valid Kakao access token
- Token might have expired
- Verify KAKAO_CLIENT_ID is correct

## Next Steps

1. Review the complete documentation in `AUTH_FEATURES.md`
2. Review implementation details in `IMPLEMENTATION_SUMMARY.md`
3. Test each endpoint thoroughly
4. Integrate with your Flutter mobile app
5. Configure OAuth credentials for production

## Mobile App Integration

For integrating these endpoints in your Flutter app, you'll need:

**Google Sign-In:**
```yaml
# pubspec.yaml
dependencies:
  google_sign_in: ^6.1.0
```

**Kakao Login:**
```yaml
# pubspec.yaml
dependencies:
  kakao_flutter_sdk: ^1.5.0
```

See `AUTH_FEATURES.md` for Flutter code examples.

---

**All features are implemented and ready for testing!**
