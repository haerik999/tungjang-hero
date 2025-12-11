import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/auth/auth_state_service.dart';
import '../../../../core/auth/data_merge_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/data_merge_dialog.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _showEmailLogin = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '텅장히어로',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '빈 지갑의 영웅',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Email login form or buttons
              if (_showEmailLogin) ...[
                _buildEmailLoginForm(),
              ] else ...[
                _buildLoginButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email login button
        ElevatedButton.icon(
          onPressed: () => setState(() => _showEmailLogin = true),
          icon: const Icon(Icons.email_outlined),
          label: const Text(
            '이메일로 로그인',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Google login button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleGoogleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://www.google.com/favicon.ico',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.g_mobiledata,
                        size: 24,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Google로 로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 32),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: AppTheme.borderColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '또는',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            Expanded(child: Divider(color: AppTheme.borderColor)),
          ],
        ),

        const SizedBox(height: 32),

        // Guest mode button
        OutlinedButton.icon(
          onPressed: _handleGuestMode,
          icon: const Icon(Icons.person_outline),
          label: const Text(
            '게스트로 시작하기',
            style: TextStyle(fontSize: 16),
          ),
        ),

        const SizedBox(height: 24),

        // Register link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '계정이 없으신가요?',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            TextButton(
              onPressed: () => context.push('/auth/register'),
              child: const Text('회원가입'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _showEmailLogin = false),
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text('뒤로'),
            ),
          ),

          const SizedBox(height: 16),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: '이메일',
              labelStyle: TextStyle(color: AppTheme.textSecondary),
              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!value.contains('@')) {
                return '올바른 이메일 형식을 입력해주세요';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: '비밀번호',
              labelStyle: TextStyle(color: AppTheme.textSecondary),
              prefixIcon: Icon(Icons.lock_outlined, color: AppTheme.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Login button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          // Find email/password links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => context.push('/auth/find-email'),
                child: Text(
                  '아이디 찾기',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '|',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              TextButton(
                onPressed: () => context.push('/auth/password-reset'),
                child: Text(
                  '비밀번호 찾기',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Register link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '계정이 없으신가요?',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              TextButton(
                onPressed: () => context.push('/auth/register'),
                child: const Text('회원가입'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      await _checkAndHandleMerge();
    } else if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  /// 로그인 후 데이터 병합 확인
  Future<void> _checkAndHandleMerge() async {
    // 병합 필요 여부 확인
    final needsMerge = await ref
        .read(dataMergeServiceProvider.notifier)
        .checkMergeNeeded();

    if (mounted) {
      setState(() => _isLoading = false);

      if (needsMerge) {
        // 병합 선택 다이얼로그 표시
        await DataMergeDialog.show(context);
      }

      // 메인 화면으로 이동
      if (mounted) {
        context.go('/main');
      }
    }
  }

  void _handleGuestMode() {
    // 게스트 모드로 진입
    ref.read(appAuthProvider.notifier).enterGuestMode();
    context.go('/main');
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account == null) {
        // User cancelled the login
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      final success = await ref.read(authProvider.notifier).loginWithGoogle(idToken);

      if (success && mounted) {
        await _checkAndHandleMerge();
      } else if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Google 로그인에 실패했습니다.'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google 로그인 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }
}
