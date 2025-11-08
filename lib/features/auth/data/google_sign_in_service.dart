import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/environment.dart';

final Provider<GoogleSignInService> googleSignInServiceProvider =
    Provider<GoogleSignInService>(
  (Ref ref) => GoogleSignInService(),
);

class GoogleSignInService {
  GoogleSignInService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? _createGoogleSignIn();

  final GoogleSignIn _googleSignIn;

  static GoogleSignIn _createGoogleSignIn() {
    final String serverClientId = EnvironmentConfig.googleServerClientId;
    final String platformClientId = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => EnvironmentConfig.googleIosClientId,
      _ => EnvironmentConfig.googleClientId,
    };

    return GoogleSignIn(
      scopes: const <String>['email', 'profile'],
      serverClientId: serverClientId.isNotEmpty ? serverClientId : null,
      clientId: platformClientId.isNotEmpty ? platformClientId : null,
      forceCodeForRefreshToken: true,
    );
  }

  Future<String> signInAndGetServerAuthCode() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        throw const GoogleSignInCancelledFailure();
      }

      final GoogleSignInAuthentication authentication =
          await account.authentication;
      final String? code = authentication.serverAuthCode;

      await _googleSignIn.disconnect();

      if (code == null || code.isEmpty) {
        throw const GoogleSignInFailure(
          'Google لم تُرجِع رمز التحقق. حاول مرة أخرى.',
        );
      }

      return code;
    } on PlatformException catch (error) {
      if (error.code == GoogleSignIn.kSignInCanceledError) {
        throw const GoogleSignInCancelledFailure();
      }
      throw GoogleSignInFailure(
        error.message ?? 'فشل تسجيل الدخول بجوجل. حاول لاحقًا.',
      );
    } catch (error) {
      throw GoogleSignInFailure(error.toString());
    }
  }
}

class GoogleSignInFailure implements Exception {
  const GoogleSignInFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class GoogleSignInCancelledFailure extends GoogleSignInFailure {
  const GoogleSignInCancelledFailure()
      : super('تم إلغاء تسجيل الدخول من قبل المستخدم.');
}

