// lib/pages/LoginPage.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart'; // Import constants
import '../models/users_model.dart';
import '../api/auth_service.dart';
// import '../services/notification_service.dart'; // Uncomment when you add FCM

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  // --- ADMIN THEME (Indigo/Purple) ---
  static const Color _primaryColor = kBankPrimary; // Use constant
  static const Color _bgDark = kBankBg; // Use dark bg
  static const Color _surfaceDark = kBankSurface; // Use dark surface

  Future<String> _getUniqueDeviceId() async {
    try {
      if (Platform.isAndroid) {
        const androidIdPlugin = AndroidId();
        return await androidIdPlugin.getId() ?? "unknown_android_id";
      } else if (Platform.isIOS) {
        var deviceInfo = DeviceInfoPlugin();
        var iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? "unknown_ios_id";
      }
    } catch (_) {}
    return "unknown_device";
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    final loginId = _loginIdController.text.trim().toUpperCase();
    final password = _passwordController.text;

    if (loginId.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both ID and Password.');
      return;
    }

    // 1. Client-side Prefix Validation
    if (!loginId.startsWith('ADM')) {
      setState(
        () => _errorMessage = 'Invalid Admin ID. Must start with "ADM".',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final deviceId = await _getUniqueDeviceId();
      // String? fcmToken = await NotificationService().getFcmToken();
      String? fcmToken; // Placeholder until you integrate FCM

      User user = await AuthService().login(
        loginId,
        password,
        deviceId,
        fcmToken,
      );

      if (!mounted) return;

      // Navigate to Home
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/home', (r) => false, arguments: user);
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _attemptAutoLogin() async {
    setState(() => _isLoading = true);

    try {
      final user = await AuthService().tryAutoLogin();

      if (!mounted) return;

      if (user != null) {
        // ✅ JWT valid + admin verified → go home
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false, arguments: user);
      }
    } catch (_) {
      // Silent fail → user stays on login screen
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark, // Dark Background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Logo / Icon ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _surfaceDark, // Dark Surface
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: kBorderColor), // Subtle border
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 50,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                'Admin Portal',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: kTextWhite, // White text
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to manage operations',
                style: TextStyle(fontSize: 15, color: kTextGrey), // Grey text
              ),
              const SizedBox(height: 40),

              // --- Form Container ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _surfaceDark, // Dark Surface
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Darker shadow
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: kBorderColor), // Subtle border
                ),
                child: Column(
                  children: [
                    // Login ID Field
                    TextField(
                      controller: _loginIdController,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(
                        color: kTextWhite,
                      ), // Input text is White
                      decoration: InputDecoration(
                        labelText: 'Admin ID',
                        labelStyle: const TextStyle(color: kTextGrey),
                        hintText: 'ADM-...',
                        hintStyle: TextStyle(color: kTextGrey.withOpacity(0.5)),
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          color: _primaryColor,
                        ),
                        filled: true,
                        fillColor:
                            kBankSurfaceLight, // Slightly lighter dark bg for input
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(
                        color: kTextWhite,
                      ), // Input text is White
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: kTextGrey),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: _primaryColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: kTextGrey,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                        filled: true,
                        fillColor:
                            kBankSurfaceLight, // Slightly lighter dark bg for input
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Error Message
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: kExpenseRed.withOpacity(
                            0.1,
                          ), // Red bg with opacity
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: kExpenseRed.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: kExpenseRed,
                            fontSize: 13,
                          ), // Red text
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
