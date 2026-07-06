import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

/// Result of validating a user-entered OTP.
enum OtpStatus { valid, invalid, expired, missing }

/// Handles generation, delivery (via the Brevo transactional email API) and
/// verification of one-time passwords used to confirm an email address during
/// sign up.
///
/// Configuration is read from `--dart-define` values so that secrets never end
/// up hard-coded in the repository:
///
/// ```
/// flutter run \
///   --dart-define=BREVO_API_KEY=xkeysib-xxxxxxxx \
///   --dart-define=BREVO_SENDER_EMAIL=no-reply@yourdomain.com \
///   --dart-define=BREVO_SENDER_NAME="CampusConnect"
/// ```
///
/// Create a free API key at https://app.brevo.com → *SMTP & API → API Keys*.
/// The sender address must be a verified sender/domain in your Brevo account.
class EmailOtpService {
  EmailOtpService._();

  /// Singleton instance — the pending OTP is kept in memory between the sign up
  /// form and the verification screen.
  static final EmailOtpService instance = EmailOtpService._();

  // ── Brevo configuration ────────────────────────────────────────────────
  static const String _apiKey =
      String.fromEnvironment('BREVO_API_KEY', defaultValue: '');
  static const String _senderEmail = String.fromEnvironment(
    'BREVO_SENDER_EMAIL',
    defaultValue: 'no-reply@campusconnect.app',
  );
  static const String _senderName = String.fromEnvironment(
    'BREVO_SENDER_NAME',
    defaultValue: 'CampusConnect',
  );

  static final Uri _endpoint = Uri.parse('https://api.brevo.com/v3/smtp/email');

  /// How long a generated code stays valid.
  static const Duration _ttl = Duration(minutes: 10);

  String? _code;
  String? _email;
  DateTime? _expiresAt;

  bool get isConfigured => _apiKey.isNotEmpty;

  String _generateCode() {
    final rnd = Random.secure();
    // A 6-digit code in the 100000–999999 range (never leading-zero padded).
    return (100000 + rnd.nextInt(900000)).toString();
  }

  /// Generates a fresh OTP for [email] and delivers it via Brevo.
  ///
  /// Throws a [StateError] when the Brevo API key has not been configured and
  /// an [Exception] when the Brevo API rejects the request.
  Future<void> sendOtp(String email) async {
    if (!isConfigured) {
      throw StateError(
        'Brevo API key missing. Run the app with '
        '--dart-define=BREVO_API_KEY=<your key>.',
      );
    }

    final code = _generateCode();
    _code = code;
    _email = email.trim().toLowerCase();
    _expiresAt = DateTime.now().add(_ttl);

    final response = await http.post(
      _endpoint,
      headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
        'api-key': _apiKey,
      },
      body: jsonEncode({
        'sender': {'name': _senderName, 'email': _senderEmail},
        'to': [
          {'email': email.trim()},
        ],
        'subject': 'Your CampusConnect verification code',
        'htmlContent': _buildHtml(code),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Brevo rejected the request (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Validates [input] against the code most recently sent to [email].
  OtpStatus verify(String email, String input) {
    if (_code == null || _email == null || _expiresAt == null) {
      return OtpStatus.missing;
    }
    if (DateTime.now().isAfter(_expiresAt!)) {
      return OtpStatus.expired;
    }
    final matches =
        _email == email.trim().toLowerCase() && _code == input.trim();
    return matches ? OtpStatus.valid : OtpStatus.invalid;
  }

  /// Clears the pending code once sign up succeeds (or is abandoned).
  void clear() {
    _code = null;
    _email = null;
    _expiresAt = null;
  }

  String _buildHtml(String code) {
    return '''
<!DOCTYPE html>
<html>
  <body style="margin:0;padding:0;background:#F5F7FB;font-family:Segoe UI,Roboto,Arial,sans-serif;">
    <table width="100%" cellpadding="0" cellspacing="0" style="padding:32px 0;">
      <tr>
        <td align="center">
          <table width="460" cellpadding="0" cellspacing="0"
                 style="background:#ffffff;border:1px solid #E2E8F0;border-radius:16px;padding:32px;">
            <tr>
              <td style="font-size:20px;font-weight:600;color:#4F6EF7;">CampusConnect</td>
            </tr>
            <tr>
              <td style="padding-top:16px;font-size:15px;color:#334155;line-height:1.6;">
                Use the verification code below to finish creating your account.
                It expires in 10 minutes.
              </td>
            </tr>
            <tr>
              <td align="center" style="padding:28px 0;">
                <div style="display:inline-block;padding:16px 28px;background:#F5F7FB;
                            border:1px dashed #4F6EF7;border-radius:12px;
                            font-size:32px;font-weight:700;letter-spacing:8px;color:#1E293B;">
                  $code
                </div>
              </td>
            </tr>
            <tr>
              <td style="font-size:13px;color:#94A3B8;line-height:1.6;">
                If you didn't request this, you can safely ignore this email.
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>
''';
  }
}
