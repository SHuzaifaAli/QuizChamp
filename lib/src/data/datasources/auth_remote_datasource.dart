import 'package:google_sign_in/google_sign_in.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getSignedInUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({required this.googleSignIn});

  @override
  Future<UserModel?> getSignedInUser() async {
    final account = await googleSignIn.signInSilently();
    if (account != null) {
      return UserModel.fromGoogleAccount(account);
    }
    return null;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        throw UserCancelledAuthFailure();
      }
      return UserModel.fromGoogleAccount(account);
    } on UserCancelledAuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await googleSignIn.signOut();
  }
}
