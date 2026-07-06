import 'package:flutter/material.dart';

import 'services/email_otp_service.dart';

/// Screen shown after a sign up form is submitted. The user must enter the OTP
/// that was emailed to [email] before their account is actually created.
///
/// [onVerified] is invoked only once the correct, non-expired code is entered.
/// It should perform the real account creation (Firebase Auth + Firestore) and
/// throw on failure so the error can be surfaced here.
class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.onVerified,
  });

  final String email;
  final Future<void> Function() onVerified;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otp = TextEditingController();
  bool _loading = false;
  bool _resending = false;

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  Future<void> _verify() async {
    final status = EmailOtpService.instance.verify(widget.email, _otp.text);

    switch (status) {
      case OtpStatus.expired:
        _snack('That code has expired. Please request a new one.', error: true);
        return;
      case OtpStatus.missing:
        _snack('No code found. Please request a new one.', error: true);
        return;
      case OtpStatus.invalid:
        _snack('Incorrect code. Please try again.', error: true);
        return;
      case OtpStatus.valid:
        break;
    }

    setState(() => _loading = true);
    try {
      await widget.onVerified();
      EmailOtpService.instance.clear();
      // On success the caller-provided callback has created the account; the
      // navigator is popped back so the auth-driven routing can take over.
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _snack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await EmailOtpService.instance.sendOtp(widget.email);
      _snack('A new code has been sent to ${widget.email}.');
    } catch (e) {
      _snack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "Verify your email",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.mark_email_read_outlined,
                    size: 40, color: Color(0xFF4F6EF7)),
                const SizedBox(height: 16),
                const Text(
                  "Enter the 6-digit code",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  "We sent a verification code to ${widget.email}. "
                  "Enter it below to finish creating your account.",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 12),
                  decoration: const InputDecoration(
                    counterText: "",
                    border: OutlineInputBorder(),
                    hintText: "••••••",
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _verify,
                          child: const Text("Verify & Create Account"),
                        ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _resending ? null : _resend,
                    child: Text(
                      _resending ? "Sending..." : "Resend code",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
