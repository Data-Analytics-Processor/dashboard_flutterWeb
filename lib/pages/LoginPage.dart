// lib/pages/LoginPage.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
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
  }

  // --- NEW LIGHT THEME COLORS ---
  static const Color _bgWhite = Color(0xFFFFFFFF); // Clean White Background
  static const Color _surfaceWhite = Color(0xFFFFFFFF); // White Surface
  static const Color _primaryNavy = Color(0xFF0A2540); // Deep Navy Blue Highlight
  static const Color _textBlack = Color(0xFF1E293B); // Slate Black for main text
  static const Color _textGrey = Color(0xFF64748B); // Cool Grey for subtext
  static const Color _borderColor = Color(0xFFE2E8F0); // Light Grey Border
  static const Color _inputFill = Color(0xFFF8FAFC); // Very light grey for inputs
  static const Color _errorRed = Color(0xFFEF4444); // Error Red

  Future<String> _getUniqueDeviceId() async {
    // Web browsers do not have a hardware device ID.
    // If we are on web, we just return a placeholder string.
    if (kIsWeb) return "web_browser_client";

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

    if (!loginId.startsWith('ADM')) {
      setState(() => _errorMessage = 'Invalid Admin ID. Must start with "ADM".');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final deviceId = await _getUniqueDeviceId();
      // String? fcmToken = await NotificationService().getFcmToken();
      String? fcmToken; 

      User user = await AuthService().login(
        loginId,
        password,
        deviceId,
        fcmToken,
      );

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false, arguments: user);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite, 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            // Constraint ensures it looks like a clean card on Web, and fills screen on Mobile
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Logo / Icon ---
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _primaryNavy.withOpacity(0.05), // Subtle navy bg
                        shape: BoxShape.circle,
                        border: Border.all(color: _primaryNavy.withOpacity(0.1)),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 48,
                        color: _primaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Admin Portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _textBlack,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to manage operations',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: _textGrey), 
                  ),
                  const SizedBox(height: 40),

                  // --- Form Container ---
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: _surfaceWhite, 
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _textBlack.withOpacity(0.04), // Very soft shadow for depth
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: _borderColor), 
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // Admin ID Label & Field
                        const Text("Admin ID", style: TextStyle(color: _textBlack, fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _loginIdController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(color: _textBlack, fontWeight: FontWeight.w500), 
                          decoration: InputDecoration(
                            hintText: 'ADM-...',
                            hintStyle: TextStyle(color: _textGrey.withOpacity(0.5)),
                            prefixIcon: const Icon(Icons.badge_outlined, color: _textGrey, size: 20),
                            filled: true,
                            fillColor: _inputFill, 
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _primaryNavy, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          ),
                        ),
                        
                        const SizedBox(height: 20),

                        // Password Label & Field
                        const Text("Password", style: TextStyle(color: _textBlack, fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(color: _textBlack, fontWeight: FontWeight.w500), 
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(color: _textGrey.withOpacity(0.5)),
                            prefixIcon: const Icon(Icons.lock_outline, color: _textGrey, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: _textGrey,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            filled: true,
                            fillColor: _inputFill, 
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _primaryNavy, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Error Message
                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: _errorRed.withOpacity(0.08), 
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _errorRed.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: _errorRed, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: _errorRed, fontSize: 13, fontWeight: FontWeight.w500), 
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryNavy,
                              foregroundColor: Colors.white, // Text/Spinner color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }
}