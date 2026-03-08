import 'package:flutter/material.dart';


class ForgotPasswordOtpScreen extends StatefulWidget {
  final Future<void> Function(String email) onSendOtp;
  final Future<void> Function(String email, String otp, String newPassword) onResetPassword;

  const ForgotPasswordOtpScreen({
    super.key,
    required this.onSendOtp,
    required this.onResetPassword,
  });

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;
  String? _error;

  Future<void> _sendOtp() async {
    setState(() { _loading = true; _error = null; });
    try {
      await widget.onSendOtp(_emailController.text.trim());
      setState(() { _otpSent = true; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _resetPassword() async {
    setState(() { _loading = true; _error = null; });
    try {
      await widget.onResetPassword(
        _emailController.text.trim(),
        _otpController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password (OTP)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              enabled: !_otpSent,
            ),
            if (_otpSent) ...[
              SizedBox(height: 16),
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'OTP'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
            ],
            SizedBox(height: 24),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 12),
            ],
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _otpSent ? _resetPassword : _sendOtp,
                    child: Text(_otpSent ? 'Reset Password' : 'Send OTP'),
                  ),
          ],
        ),
      ),
    );
  }
}
